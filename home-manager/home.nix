{
  config,
  hostname,
  inputs,
  lib,
  pkgs,
  username,
  ...
}: let
  isPersonalMachine = hostname == "carbo";
  isWorkMachine = !isPersonalMachine;

  unfreePackages =
    [
      "claude-code"
      "discord"
      "dracula-dark-colorscheme" # firefox theme
      "fmod"
      "google-chrome"
      "lmstudio"
      "slack"
      "vivaldi"
      "zoom"
      "zsh-abbr"
    ]
    ++ (
      if isWorkMachine
      then [
        # tiv
        "1password"
        "1password-cli"
        "1password-gui"
      ]
      else ["signal-desktop"]
    );

  ezaFlags = "--group-directories-first";
  ezaLong = "${ezaFlags} --color-scale --git -l";
  shellAbbrs = {
    ls = "eza ${ezaFlags}";
    ll = "eza ${ezaLong}";
    la = "eza ${ezaLong} -a";
    lah = "eza ${ezaLong} -ah";
    lsdu = "eza ${ezaLong} -ah --total-size";

    gcom = "git checkout main";
    gum = "git fetch origin main:main";

    # I really hope I never need to use ghostscript.
    gs = "git status";

    hm = "nh home switch --ask";
    nos = "nh os switch --ask";
  };

  neovimConfigured = pkgs.neovim;

  inherit (pkgs.stdenv.hostPlatform) system;
in {
  imports = [
    ./modules
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) unfreePackages;
    };
  };

  home = {
    inherit username;
    homeDirectory =
      if username == "root"
      then "/root"
      else "/home/${username}";

    sessionVariables = {
      EDITOR = "nvim";
      EZA_ICONS_AUTO = "1";
      EZA_MIN_LUMINANCE = "50";
      NH_FLAKE = "/home/adam/nixos-config";
      BEMENU_OPTS = "-H 30 --tb '#6272a4' --tf '#f8f8f2' --fb '#282a36' --ff '#f8f8f2' --nb '#282a36' --nf '#6272a4' --hb '#44475a' --hf '#50fa7b' --sb '#44475a' --sf '#50fa7b' --scb '#282a36' --scf '#ff79c6'";
    };

    shellAliases = {
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };

  home.file."bin" = {
    source = ../scripts;
    recursive = true; # link recursively
    executable = true; # make all files executable
  };

  home.packages = with pkgs; [
    bat
    duc
    eza # A modern replacement for ‘ls’
    fd # Modern `find`
    fzf # A command-line fuzzy finder
    jujutsu
    jq
    imagemagick
    libwebp
    fastfetch
    pdftk
    procs
    ripgrep
    vgrep
    tmux
    xdg-user-dirs

    # networking tools
    aria2 # A lightweight multi-protocol & multi-source command-line download utility

    # nix related
    #
    alejandra
    any-nix-shell

    # https://nina.asha.software/
    inputs.nina.outputs.packages.${system}.default

    # dev
    claude-code
    devenv
    elmPackages.elm
    elmPackages.elm-format
    elmPackages.elm-language-server
    elmPackages.elm-review
    gh
    lua-language-server
    nil
    nodejs_24
    shellcheck
    shfmt
    stylua
    tailwindcss-language-server
    terraform-ls
    tflint
    tflint-plugins.tflint-ruleset-aws
    typescript-language-server
    vscode-langservers-extracted

    neovimConfigured
  ];

  programs.difftastic.enable = true;

  programs.git = {
    enable = true;

    settings = {
      branch.autoSetupRebase = "always";
      checkout.guess = true;
      commit.gpgsign = false;
      core.editor = lib.getExe neovimConfigured;
      init.defaultbranch = "main";
      merge.guitool = lib.getExe pkgs.meld;
      #  cmd = ''meld "$LOCAL" "$MERGED" "$REMOTE" --output "$MERGED"'';
      pull.rebase = true;
      push.autoSetupRemote = true;
      rebase.autoStash = true;
      url = {
        "git+ssh://git@github.com/".insteadOf = ["gh:" "git://github.com/" "ssh://git@github.com:"];
        "git+ssh://git@github.com/".pushInsteadOf = ["git://github.com/" "https://github.com/" "ssh://git@github.com:"];
      };

      user = {
        name = "Adam DiCarlo";
        email = "adam@bikko.org";
        # My 2023 GPG key
        signingkey = "C8CB1DB6E4EA5801";
      };
    };
  };

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      PATH=$HOME/nixos-config/nvf/result/bin:$PATH
      export PATH
    '';
  };

  programs.atuin = {
    enable = true;
    flags = ["--disable-up-arrow"];
    settings = {
      auto_sync = true;
      sync_frequency = "2m";
      update_check = false;
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    autosuggestion.enable = true;
    enableCompletion = true;
    enableVteIntegration = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      if [[ -z "$(declare -f custom_cd_hook_ls)" ]]; then
        custom_cd_hook_ls() {
          emulate -L zsh
          [[ $PWD != "$custom_cd_hook_ls_last_dir" ]] && ${shellAbbrs.lah}
          custom_cd_hook_ls_last_dir=$PWD
        }
        add-zsh-hook chpwd custom_cd_hook_ls
      fi

      path=("$HOME/nixos-config/nvf/result/bin" $path)
      export PATH

      # don't show `nix-shell-env` in devbox shell prompt
      zstyle :prompt:pure:environment:nix-shell show no

      # Bind 'v' to edit command line in EDITOR when in vi command mode.
      autoload edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd v edit-command-line

      # Colemak movement
      bindkey -a "j" vi-backward-char
      bindkey -a "h" up-line-or-history
      bindkey -a "k" down-line-or-history

      ${pkgs.any-nix-shell}/bin/any-nix-shell zsh | source /dev/stdin
    '';

    # `devbox shell` mysteriously fails to execute project init_hook if ZDOTDIR
    # is, e.g. $HOME/.config/zsh.
    #
    # dotDir = ".config/zsh";

    plugins = let
      ohmyzsh = pkgs.fetchgit {
        url = "https://github.com/ohmyzsh/ohmyzsh";
        rev = "b6bb133f230847ed0b3f9f4e25f2ceb874ca6c91";
        hash = "sha256-XBAFP+lUBgOy7Qw2zRUc0M1Q5/PJCc8/R88lX2xaNY0=";
        sparseCheckout = [
          "lib/clipboard.zsh"
          "plugins/git/git.plugin.zsh"
        ];
      };
    in [
      {
        name = "git";
        file = "plugins/git/git.plugin.zsh";
        src = ohmyzsh;
      }
      {
        name = "clipboard";
        file = "lib/clipboard.zsh";
        src = ohmyzsh;
      }
      {
        name = "pure";
        file = "pure.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "sindresorhus";
          repo = "pure";
          rev = "4e0ce0a2f8576894e5dad83857e9a9851faa0f5b";
          hash = "sha256-tDfk4QZ2ApkNE4nPeeD6UVSKSIgld5MdP0qFFheygZA=";
          sparseCheckout = ["async.zsh" "pure.zsh"];
        };
      }
    ];
    zsh-abbr = {
      enable = true;
      abbreviations = shellAbbrs;
    };
  };

  programs.lazygit = {
    enable = true;
  };

  # starship - a customizable prompt for any shell
  programs.starship = {
    enable = false;
    # custom settings
    settings = {
      add_newline = true;
      aws.disabled = false;
      gcloud.disabled = true;
      line_break.disabled = false;
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "Host *" = {
        AddKeysToAgent = "yes";
        SetEnv = {
          TERM = "xterm-256color";
        };
      };
      "Host oddsy" = {
        ForwardAgent = true;
        HostName = "10.0.0.2";
        User = "adam";
      };
      "Host opti" = {
        ForwardAgent = true;
        HostName = "10.0.0.5";
        User = "adam";
      };
      "Host github.com" = {
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
        IdentitiesOnly = true;
      };
      "Host panthalassa.net" = {
        User = "bikko";
      };
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
