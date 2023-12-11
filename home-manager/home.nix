{
  config,
  pkgs,
  ...
}: let
  ezaFlags = "--group-directories-first";
  ezaLong = "${ezaFlags} --color-scale --git --icons -l";
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
  };
in {
  imports = [
    ../modules/default.nix
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = _: true;
      # allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
      #   "zsh-abbr-5.2.0"
      # ];
    };
  };

  home = {
    username = "adam";
    homeDirectory = "/home/adam";

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
    eza # A modern replacement for ‘ls’
    fd # Modern `find`
    fzf # A command-line fuzzy finder
    jq
    imagemagick
    libwebp
    neofetch
    procs
    ripgrep

    # networking tools
    aria2 # A lightweight multi-protocol & multi-source command-line download utility

    # nix related
    #
    alejandra
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # dev
    devbox # via ./flakes/devbox
    elmPackages.elm
    elmPackages.elm-format
    elmPackages.elm-language-server
    elmPackages.elm-review
    gh
    lua-language-server
    nil
    nodePackages.typescript-language-server
    nodejs_18
    shellcheck
    shfmt
    stylua
    tailwindcss-language-server
    terraform-ls
    tflint
    tflint-plugins.tflint-ruleset-aws
    vscode-langservers-extracted
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
      core.editor = "${pkgs.neovim}/bin/nvim";
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

  programs.autojump = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableVteIntegration = true;

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
        name = "git";
        file = "lib/clipboard.zsh";
        src = ohmyzsh;
      }
    ];
    prezto = {
      enable = true;
      prompt.theme = "pure";
    };
    syntaxHighlighting = {
      enable = true;
    };
    zsh-abbr = {
      enable = true;
      abbreviations = shellAbbrs;
    };
  };

  programs.fish = {
    enable = true;

    shellInit = ''
      set -g fish_greeting
      function chdir_hook_ls --on-variable=PWD
        eza -l
      end
    '';

    shellAbbrs = shellAbbrs;
    functions = {
    };

    plugins = [
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "plugin-git";
        src = pkgs.fetchFromGitHub {
          owner = "jhillyerd";
          repo = "plugin-git";
          # https://github.com/jhillyerd/plugin-git/issues/102
          rev = "c2b38f53f0b04bc67f9a0fa3d583bafb3f558718";
          sha256 = "sha256-efKPbsXxjHm1wVWPJCV8teG4DgZN5dshEzX8PWuhKo4=";
        };
      }
    ];
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