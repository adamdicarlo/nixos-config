{ config, pkgs, mkAbsoluteSymlink, ... }:

{
  imports = [
    ./modules/default.nix
  ];

  home.username = "adam";
  home.homeDirectory = "/home/adam";

  home.keyboard.layout = "us";
  home.keyboard.variant = "colemak";
  home.keyboard.xkbOptions = [ "altwin:swap_lalt_lwin" ];

  home.shellAliases = {
    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  };

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # set cursor size and dpi
  xresources.properties = {
    "Xcursor.size" = 24;
    "Xft.dpi" = 96;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [

    kitty
    kitty-img
    kitty-themes

    neofetch
    nnn # terminal file manager

    # utils
    exa # A modern replacement for ‘ls’
    fd
    fzf # A command-line fuzzy finder
    jq
    procs
    ripgrep

    # networking tools
    aria2 # A lightweight multi-protocol & multi-source command-line download utility

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # lsp: https://github.com/oxalica/nil
    nil

    # productivity
    glow # markdown previewer in terminal
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    diff-so-fancy.enable = true;
    # defaultBranch = "main";
    userName = "Adam DiCarlo";
    userEmail = "97462+adamdicarlo@users.noreply.github.com";
    extraConfig = {
      # My 2023 GPG key
      user.signingKey = "C8CB1DB6E4EA5801";
      pull.rebase = true;
      core.editor = "nvim";
      init.defaultbranch = "main";
      commit.gpgsign = true;
      url = {
        "ssh://git@github.com:".insteadOf = [ "gh:" "git://github.com/" ];
        "ssh://git@github.com:".pushInsteadOf = [ "git://github.com/" "https://github.com/" ];
        "github-work:adaptivsystems/".insteadOf = "git@github.com:adaptivsystems/";
      };
    };

    includes = [
      { condition = "gitdir:~/work/";
        contents = {
          user.email = "adam@adaptiv.systems";
          user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTEAAAAIO1e83u2v7t+ePxp3RXARC3tnXiPcC950LMDi2sdTDAc";
          gpg = {
            format = "ssh";
            program = "/opt/1Password/op-ssh-sign";
          };
        };
      }
    ];
  };

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };

  programs.bash = {
    enable = true;
    # enableCompletion = true;
    # TODO add your cusotm bashrc here
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';
  };

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "plugin-git";
        src = pkgs.fishPlugins.plugin-git.src;
      }
    ];
  };

  programs.lazygit = {
    enable = true;
  };
  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    theme = "Dracula";
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = false;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    enableScDaemon = false;
    enableSshSupport = true;
    sshKeys = [ "689797597435372AAE566787A29AFFB7B862D0B6" ];
  };

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  # programs.alacritty = {
  #  enable = true;
  #  # custom settings
  #  settings = {
  #    env.TERM = "xterm-256color";
  #    font = {
  #      size = 12;
  #      draw_bold_text_with_bright_colors = true;
  #    };
  #    scrolling.multiplier = 5;
  #    selection.save_to_clipboard = true;
  #  };
  #};

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
