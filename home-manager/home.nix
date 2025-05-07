{
  config,
  hostname,
  inputs,
  lib,
  pkgs,
  system,
  username,
  ...
}: let
  isPersonalMachine = hostname == "carbo";
  isWorkMachine = !isPersonalMachine;

  unfreePackages =
    [
      "discord"
      "dracula-dark-colorscheme" # firefox theme
      "fmod"
      "google-chrome"
      "slack"
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

  neovimConfigured = inputs.my-nvf.packages.${system}.default;
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
    duc
    eza # A modern replacement for ‘ls’
    fd # Modern `find`
    fzf # A command-line fuzzy finder
    jujutsu
    jq
    imagemagick
    libwebp
    neofetch
    procs
    ripgrep
    tmux

    # networking tools
    aria2 # A lightweight multi-protocol & multi-source command-line download utility

    # nix related
    #
    alejandra
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # dev
    inputs.devbox.packages.${system}.default
    inputs.fh.packages.${system}.default
    elmPackages.elm
    elmPackages.elm-format
    elmPackages.elm-language-server
    elmPackages.elm-review
    gh
    lua-language-server
    nil
    nodePackages.typescript-language-server
    nodejs_20
    shellcheck
    shfmt
    stylua
    tailwindcss-language-server
    terraform-ls
    tflint
    tflint-plugins.tflint-ruleset-aws
    vscode-langservers-extracted

    neovimConfigured
  ];

  programs.git = {
    enable = true;

    difftastic.enable = true;
    userName = "Adam DiCarlo";
    userEmail = "adam@bikko.org";
    extraConfig = {
      branch.autoSetupRebase = "always";
      checkout.guess = true;
      commit.gpgsign = true;
      core.editor = lib.getExe neovimConfigured;
      init.defaultbranch = "main";
      merge.guitool = "meld";
      #  cmd = ''meld "$LOCAL" "$MERGED" "$REMOTE" --output "$MERGED"'';
      pull.rebase = true;
      push.autoSetupRemote = true;
      rebase.autoStash = true;
      url = {
        "git+ssh://git@github.com/".insteadOf = ["gh:" "git://github.com/" "ssh://git@github.com:"];
        "git+ssh://git@github.com/".pushInsteadOf = ["git://github.com/" "https://github.com/" "ssh://git@github.com:"];
      };
      # My 2023 GPG key
      user.signingkey = "C8CB1DB6E4EA5801";
    };
  };

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
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
    addKeysToAgent = "yes";
    matchBlocks = {
      "*" = {
        setEnv = {
          TERM = "xterm-256color";
        };
      };
      "panthalassa.net" = {
        user = "bikko";
      };
      oddsy = {
        hostname = "10.0.0.2";
        user = "adam";
        forwardAgent = true;
      };
      opti = {
        hostname = "10.0.0.5";
        user = "adam";
        forwardAgent = true;
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
