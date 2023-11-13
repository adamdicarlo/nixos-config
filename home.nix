{
  config,
  pkgs,
  ...
}: let
  shellAbbrs = {
    ls = "eza";
    ll = "eza -l";
    la = "eza -la";
    lah = "eza -lah";

    gcom = "git checkout main";

    # I really hope I never need to use ghostscript.
    gs = "git status";
  };
in {
  imports = [
    ./modules/default.nix
  ];

  home = {
    username = "adam";
    homeDirectory = "/home/adam";

    shellAliases = {
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };

    pointerCursor = {
      gtk.enable = true;
      # x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Amber";
      size = 32;
    };
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };
    iconTheme = {
      package = pkgs.libsForQt5.breeze-icons;
      name = "breeze-dark";
    };
    font = {
      name = "Sans";
      size = 11;
    };
  };

  home.file."bin" = {
    source = ./scripts;
    recursive = true; # link recursively
    executable = true; # make all files executable
  };

  home.file."Pictures/wallpaper" = {
    source = ./wallpaper;
    recursive = true;
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

  home.packages = with pkgs; [
    kitty
    kitty-img
    kitty-themes

    neofetch
    nnn # terminal file manager

    # utils
    eza # A modern replacement for ‘ls’
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
    alejandra

    # Wayland, GUI stuff
    cliphist
    grim
    hyprpicker
    imv
    mako
    networkmanagerapplet
    nwg-displays
    playerctl
    slurp
    swappy
    sway
    swaybg
    swayidle
    swaylock
    swaynag-battery
    udiskie
    waybar
    wbg
    wev
    wf-recorder
    wl-clipboard
    wlogout
    wlsunset
    wofi
    wofi-emoji
    wtype
    xdragon

    # lsp: https://github.com/oxalica/nil
    nil
    lua-language-server
    stylua

    # productivity
    glow # markdown previewer in terminal
    nerdfonts

    _1password-gui
    devbox # via ./flakes/devbox
    dolphin
    gh
    google-chrome
    meld
    slack
  ];

  services.cliphist = {
    enable = true;
    systemdTarget = "hyprland-session.target";
  };

  services.swayidle = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    timeouts = [
      {
        timeout = 900;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        timeout = 915;
        command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
    ];
  };

  programs.swaylock = {
    enable = false;
    settings = {
      bs-hl-color = "ee2e24FF";
      caps-lock-bs-hl-color = "ee2e24FF";
      caps-lock-key-hl-color = "ffd204FF";
      color = "22D0D2FF";
      font = "Sans";
      ignore-empty-password = true;
      indicator-caps-lock = true;
      indicator-thickness = "60";

      inside-caps-lock-color = "009ddc00";
      inside-clear-color = "ffd20400";
      inside-color = "009ddc00";
      inside-ver-color = "d9d8d800";
      inside-wrong-color = "ee2e2400";

      key-hl-color = "009ddcFF";

      line-caps-lock-color = "009ddcFF";
      line-clear-color = "ffd204FF";
      line-color = "009ddc00";
      line-ver-color = "d9d8d8FF";
      line-wrong-color = "ee2e24FF";

      ring-caps-lock-color = "231f20D9";
      ring-clear-color = "231f20D9";
      ring-color = "231f20D9";
      ring-ver-color = "231f20D9";
      ring-wrong-color = "231f20D9";

      separator-color = "231f20DD";
      show-failed-attempts = true;
      show-keyboard-layout = true;

      text-caps-lock-color = "009ddc00";
      text-clear-color = "ffd20400";
      text-color = "009ddc00";
      text-ver-color = "d9d8d800";
      text-wrong-color = "ee2e2400";
    };
  };

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };
    settings = {
      mainBar = {
        # From https://github.com/Pipshag/dotfiles_nord/blob/master/.config/waybar/config
        "layer" = "top"; # Waybar at top layer
        "position" = "top"; # Waybar position (top|bottom|left|right)
        # "height" = 36; # Waybar height (to be removed for auto height)
        # Archived modules
        # "custom/gpu" "bluetooth"  "custom/weather" "temperature" "sway/window"
        # Choose the order of the modules
        "modules-left" = [
          "hyprland/workspaces"
          # "custom/scratchpad-indicator"
          # "sway/mode"
          # "custom/media"
        ];
        "modules-center" = ["hyprland/window"];
        "modules-right" = [
          "idle_inhibitor"
          # "custom/cpugovernor",
          "cpu"
          "temperature"
          # "custom/gpu",
          "pulseaudio"
          "bluetooth"
          "network"
          "tray"
          "clock"
        ];
        # Modules configuration
        "hyprland/workspaces" = {
          "all-outputs" = true;
          "format" = "{icon}";
          "format-icons" = {
            "1" = "<span color=\"#D8DEE9\"></span>";
            "2" = "<span color=\"#88C0D0\"></span>";
            "3" = "<span color=\"#A3BE8C\"></span>";
            "4" = "<span color=\"#D8DEE9\"></span>";
            "urgent" = "";
            "focused" = "";
            "default" = "";
          };
        };
        "sway/mode" = {
          "format" = "<span style=\"italic\">{}</span>";
        };
        "hyprland/window" = {
          "format" = "{class} {}";
          "rewrite" = {
            "(.*) — Mozilla Firefox" = "🌎 $1";
            "^kitty (.*)" = " $1";
            "nvim (.*)" = "> [$1]";
          };
        };
        "bluetooth" = {
          "interval" = 30;
          "format" = "{icon}";
          # "format-alt" = "{status}";
          "format-icons" = {
            "enabled" = "";
            "disabled" = "";
          };
          "on-click" = "blueberry";
        };
        "idle_inhibitor" = {
          "format" = "{icon}";
          "format-icons" = {
            "activated" = "";
            "deactivated" = "";
          };
          "tooltip" = "true";
        };
        "tray" = {
          #"icon-size = 11;
          "spacing" = 5;
        };
        "clock" = {
          "format" = "  {:%r     %b %e}";
          "tooltip-format" = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
          "today-format" = "<b>{}</b>";
          "on-click" = "gnome-calendar";
        };
        "cpu" = {
          "interval" = "1";
          "format" = "  {max_frequency}GHz <span color=\"darkgray\">| {usage}%</span>";
          "max-length" = 13;
          "min-length" = 13;
          "on-click" = "kitty -e gtop --sort-key PERCENT_CPU";
          "tooltip" = false;
        };
        "temperature" = {
          #"thermal-zone" = 1;
          "interval" = "4";
          "hwmon-path" = "/sys/class/hwmon/hwmon3/temp1_input";
          "critical-threshold" = 74;
          "format-critical" = "  {temperatureC}°C";
          "format" = "{icon}  {temperatureC}°C";
          "format-icons" = ["" "" ""];
          "max-length" = 7;
          "min-length" = 7;
        };
        "network" = {
          # "interface" = "wlan0", # (Optional) To force the use of this interface,
          "format-wifi" = "  {essid}";
          "format-ethernet" = "{ifname}: {ipaddr}/{cidr} ";
          "format-linked" = "{ifname} (No IP) ";
          "format-disconnected" = "";
          "format-alt" = "{ifname}: {ipaddr}/{cidr}";
          "family" = "ipv4";
          "tooltip-format-wifi" = "  {ifname} @ {essid}\nIP: {ipaddr}\nStrength: {signalStrength}%\nFreq: {frequency}MHz\n {bandwidthUpBits}  {bandwidthDownBits}";
          "tooltip-format-ethernet" = " {ifname}\nIP: {ipaddr}\n {bandwidthUpBits}  {bandwidthDownBits}";
        };
        "pulseaudio" = {
          "scroll-step" = 3; # %, can be a float
          "format" = "{icon} {volume}% {format_source}";
          "format-bluetooth" = "{volume}% {icon} {format_source}";
          "format-bluetooth-muted" = " {icon} {format_source}";
          "format-muted" = " {format_source}";
          #"format-source" = "{volume}% ";
          #"format-source-muted" = "";
          "format-source" = "";
          "format-source-muted" = "";
          "format-icons" = {
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = ["" "" ""];
          };
          "on-click" = "pavucontrol";
          "on-click-right" = "wpctl set-mute @DEFAULT_SOURCE@ toggle";
        };
        "custom/weather" = {
          "exec" = "curl 'https://wttr.in/?format=1'";
          "interval" = 3600;
        };
        "custom/gpu" = {
          "exec" = "$HOME/.config/waybar/custom_modules/custom-gpu.sh";
          "return-type" = "json";
          "format" = "  {}";
          "interval" = 2;
          "tooltip" = "{tooltip}";
          "max-length" = 19;
          "min-length" = 19;
          "on-click" = "powerupp";
        };
        "custom/cpugovernor" = {
          "format" = "{icon}";
          "interval" = "30";
          "return-type" = "json";
          "exec" = "$HOME/.config/waybar/custom_modules/cpugovernor.sh";
          "min-length" = 2;
          "max-length" = 2;
          "format-icons" = {
            "perf" = "";
            "sched" = "";
          };
        };
        "custom/media" = {
          "format" = "{icon} {}";
          "return-type" = "json";
          "max-length" = 40;
          "format-icons" = {
            "spotify" = "";
            "default" = "🎜";
          };
          "escape" = true;
          "exec" = "$HOME/.config/waybar/mediaplayer.py 2> /dev/null";
          # "exec" = "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null" # Filter player based on name
        };
      };
    };
  };

  services.wlsunset = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    temperature = {
      day = 4300;
      night = 2800;
    };
    latitude = "45.6";
    longitude = "122.7";
  };

  programs.git = {
    enable = true;

    difftastic.enable = true;
    userName = "Adam DiCarlo";
    userEmail = "adam@bikko.org";
    extraConfig = {
      branch.autoSetupRebase = "always";
      checkout.guess = true;
      commit.gpgsign = true;
      core.editor = "nvim";
      init.defaultbranch = "main";
      merge.guitool = "meld";
      #  cmd = ''meld "$LOCAL" "$MERGED" "$REMOTE" --output "$MERGED"'';
      pull.rebase = true;
      push.autoSetupRemote = true;
      rebase.autoStash = true;
      url = {
        "git+ssh://git@github.com/".insteadOf = ["gh:" "git://github.com/" "ssh://git@github.com:"];
        "git+ssh://git@github.com/".pushInsteadOf = ["git://github.com/" "https://github.com/" "ssh://git@github.com:"];
        "github-work:adaptivsystems/".insteadOf = "git@github.com:adaptivsystems/";
      };
      # My 2023 GPG key
      user.signingkey = "C8CB1DB6E4EA5801";
    };

    includes = [
      {
        condition = "gitdir:~/work/";
        contents = {
          user.email = "adam@adaptiv.systems";
          user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1e83u2v7t+ePxp3RXARC3tnXiPcC95OLMDi2sdTDAc";
          gpg = {
            format = "ssh";
            ssh = {
              allowedSignersFile = builtins.toFile "allowed-signers" ''
                adam@adaptiv.systems ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHuKcZZc8H73Brm6B7wIcGuInLH5t48ezXRDw4rurAi
                adam@adaptiv.systems ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1e83u2v7t+ePxp3RXARC3tnXiPcC95OLMDi2sdTDAc
              '';
              program = "${pkgs._1password-gui}/bin/op-ssh-sign";
            };
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

  # cribbed and adapted from Charlotte Van Petegem's configs
  # at https://git.chvp.be/chvp/nixos-config
  programs.firefox = let
    ff2mpv-host = pkgs.stdenv.mkDerivation rec {
      pname = "ff2mpv";
      version = "4.0.0";
      src = pkgs.fetchFromGitHub {
        owner = "woodruffw";
        repo = "ff2mpv";
        rev = "v${version}";
        sha256 = "sxUp/JlmnYW2sPDpIO2/q40cVJBVDveJvbQMT70yjP4=";
      };
      buildInputs = [pkgs.python3];
      buildPhase = ''
        sed -i "s#/home/william/scripts/ff2mpv#$out/bin/ff2mpv.py#" ff2mpv.json
        sed -i 's#"mpv"#"${pkgs.mpv}/bin/umpv"#' ff2mpv.py
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp ff2mpv.py $out/bin
        mkdir -p $out/lib/mozilla/native-messaging-hosts
        cp ff2mpv.json $out/lib/mozilla/native-messaging-hosts
      '';
    };
    ffPackage = pkgs.firefox.override {
      nativeMessagingHosts = [ff2mpv-host];
      pkcs11Modules = [];
      extraPolicies = {
        DisableFirefoxAccounts = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        FirefoxHome = {
          Pocket = false;
          Snippets = false;
        };
        OfferToSaveLogins = false;
        UserMessaging = {
          SkipOnboarding = true;
          ExtensionRecommendations = false;
        };
      };
    };
  in {
    enable = true;
    package = ffPackage;
    profiles.default = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
        decentraleyes
        don-t-fuck-with-paste
        dracula-dark-colorscheme
        facebook-container
        ff2mpv
        tree-style-tab
        ublock-origin
        umatrix
      ];
      settings = {
        "app.shield.optoutstudies.enabled" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.contentblocking.category" = "custom";
        "browser.download.dir" = "/home/adam/Downloads";
        "browser.newtabpage.activity-stream.feeds.recommendationprovider" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.enabled" = false;
        "browser.safebrowsing.malware.enabled" = false;
        "browser.safebrowsing.phishing.enabled" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.startup.homepage" = "about:blank";
        "browser.startup.page" = 3;
        "dom.security.https_only_mode" = true;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "network.cookie.cookieBehavior" = 1;
        "privacy.annotate_channels.strict_list.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "security.identityblock.show_extended_validation" = true;
        "toolkit.telemetry.cachedClientID" = "c0ffeec0-ffee-c0ff-eec0-ffeec0ffeec0";
      };
    };
  };

  programs.mpv = {
    enable = true;
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

  programs.carapace.enable = true;

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableVteIntegration = true;

    # `devbox shell` mysteriously fails to execute project init_hook if ZDOTDIR
    # is, e.g. $HOME/.config/zsh.
    #
    # dotDir = ".config/zsh";

    initExtra = ''
      # Automatically run devbox shell when entering adaptiv repos
      eval "$(/home/adam/work/localtools/scripts/cd-devbox)"
    '';
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
    enable = false;

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

      # https://github.com/jhillyerd/plugin-git/issues/102
      #
      # Use fork for now. Once the issue is solved and nixpkgs is updated,
      # we can use:
      #
      # {
      #   name = "plugin-git";
      #   src = pkgs.fishPlugins.plugin-git.src;
      # }
      {
        name = "plugin-git__hexclover-fork";
        src = pkgs.fetchFromGitHub {
          owner = "hexclover";
          repo = "plugin-git";
          rev = "265dc22cc53347135eba23d3128f34d9d6602a15";
          sha256 = "sha256-RzyRekfji53P/fGaN5Yme/Y3Npd3JFvI7GIykTSwucU=";
        };
      }
    ];
  };

  programs.kitty = {
    enable = true;
    theme = "Dracula";
    font = {
      package = pkgs.nerdfonts;
      name = "FiraCode Nerd Font Mono";
      size = 11;
    };
    settings = {
      enable_audio_bell = false;
      scrollback_lines = 15000;
      sync_to_monitor = false;
      visual_bell_duration = "0.2";
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

  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    enableScDaemon = false;
    enableSshSupport = true;
    sshKeys = ["689797597435372AAE566787A29AFFB7B862D0B6"];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      # See https://wiki.hyprland.org/Configuring/Monitors/
      monitor=,preferred,auto,1

      # See https://wiki.hyprland.org/Configuring/Keywords/ for more

      # Execute your favorite apps at launch
      exec-once = swaybg -m fill -i ~/Pictures/wallpaper/pexels-andy-vu-3484061.jpg
      exec-once = nm-applet --indicator
      exec-once = swaynag-battery
      exec-once = ~/.config/hypr/on-lid.sh
      exec-once = 1password --silent
      exec-once = udiskie

      # Source a file (multi-file configs)
      # source = ~/.config/hypr/myColors.conf

      # Some default env vars.
      env = XCURSOR_SIZE,24
      env = XDG_CURRENT_DESKTOP,Hyprland
      env = XDG_SESSION_DESKTOP,Hyprland
      env = XDG_SESSION_TYPE,wayland
      env = GDK_BACKEND,wayland,x11
      env = QT_QPA_PLATFORM,wayland;xcb
      env = SDL_VIDEODRIVER,wayland
      env = GBM_BACKEND,nvidia-drm
      env = LIBVA_DRIVER_NAME,nvidia
      env = __GLX_VENDOR_LIBRARY_NAME,nvidia
      env = __GL_VRR_ALLOWED,1
      env = WLR_NO_HARDWARE_CURSORS,1
      env = NIXOS_OZONE_WL,1
      env = CLUTTER_BACKEND,wayland
      env = WLR_RENDERER,vulkan
      env = TERMINAL,kitty
      env = BROWSER,google-chrome-stable


      # Clamshell mode configuration

      ## Lid is opened
      bindl=,switch:off:Lid Switch,exec, ~/.config/hypr/on-lid.sh

      ## Lid is closed
      bindl=,switch:on:Lid Switch,exec,~/.config/hypr/on-lid.sh


      # For use with Kvantam
      # env = QT_QPA_PLATFORMTHEME=qt5ct

      # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
      input {
          kb_layout = us
          kb_variant = colemak
          kb_model =
          kb_options = altwin:swap_lalt_lwin
          kb_rules =
          repeat_rate = 40
          repeat_delay = 200

          follow_mouse = 1

          scroll_method = 2fg
          natural_scroll = yes
          touchpad {
              natural_scroll = yes
              clickfinger_behavior = yes
              tap-to-click = no
          }
          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
      }

      general {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          gaps_in = 2
          gaps_out = 2
          border_size = 2
          col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          col.inactive_border = rgba(595959aa)

          layout = dwindle
      }

      decoration {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          rounding = 2

          blur {
              enabled = true
              size = 7
              passes = 4
              new_optimizations = true
          }

          blurls = lockscreen

          inactive_opacity = 0.96
          drop_shadow = yes
          shadow_range = 4
          shadow_render_power = 3
          col.shadow = rgba(1a1a1aee)
      }

      animations {
          enabled = yes

          # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

          bezier = myBezier, 0.05, 0.9, 0.1, 1.05

          animation = windows, 1, 2, default
          animation = windowsOut, 1, 3, default, popin 80%
          animation = border, 1, 5, default
          animation = borderangle, 1, 3, default
          animation = fade, 1, 3, default
          animation = workspaces, 1, 2, default
      }

      dwindle {
          # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
          pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = yes # you probably want this
      }

      master {
          # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
          new_is_master = true
      }

      gestures {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          workspace_swipe = off
      }

      # Example per-device config
      # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
      device:epic-mouse-v1 {
          sensitivity = -0.5
      }

      # Example windowrule v1
      # windowrule = float, ^(kitty)$
      # Example windowrule v2
      # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more


      # TODO:
      #
      # - test idle/lock
      # - nag-battery
      # - emoji
      # - screenshot
      # - screen record
      # - clipboard
      # - XF86AudioRaiseVolume XF86MonBrightnessUp
      # - Remove the anime girl wallpaper

      # See https://wiki.hyprland.org/Configuring/Keywords/ for more
      $mainMod = SUPER

      # See https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = $mainMod, RETURN, exec, kitty
      bind = $mainMod SHIFT, Q, killactive,

      bind = $mainMod      , S     , exec, ~/bin/grim-swappy.sh
      bind = $mainMod SHIFT, S     , exec, ~/bin/wf-record-area.sh
      bind = $mainMod      , F     , exec, dolphin
      bind = $mainMod      , E     , exec, pkill wofi || wofi-emoji
      bind = $mainMod SHIFT, E     , exec, wlogout --protocol layer-shell
      bind = $mainMod SHIFT, SPACE , togglefloating,
      bind = $mainMod      , SPACE , exec, pkill wofi || wofi --show drun
      bind = $mainMod      , ESCAPE, exec, swaylock # Lock the screen
      bind = $mainMod      , P     , pseudo, # dwindle
      bind = $mainMod      , G     , togglesplit, # dwindle
      bind = $mainMod SHIFT, F     , fullscreen,
      bind = $mainMod      , Y     , exec, cliphist list | wofi -dmenu | cliphist decode | wl-copy

      # Audio
      bind=,XF86AudioPlay,exec,playerctl play-pause
      bind=,XF86AudioPrev,exec,playerctl previous
      bind=,XF86AudioNext,exec,playerctl next

      bindl=,XF86AudioMedia,exec,playerctl play-pause
      bindl=,XF86AudioStop,exec,playerctl stop

      bindle=,XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_SINK@ 2.5%+
      bindle=,XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_SINK@ 2.5%-
      bindle=,XF86AudioMute,exec,wpctl set-mute @DEFAULT@ toggle

      # Move focus
      bind = $mainMod, J, movefocus, l
      bind = $mainMod, L, movefocus, r
      bind = $mainMod, H, movefocus, u
      bind = $mainMod, K, movefocus, d

      # Move window
      bind = $mainMod SHIFT, J, swapwindow, l
      bind = $mainMod SHIFT, L, swapwindow, r
      bind = $mainMod SHIFT, H, swapwindow, u
      bind = $mainMod SHIFT, K, swapwindow, d

      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10

      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow
    '';
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github-work" = {
        hostname = "github.com";
        user = "git";
        identityFile = "/home/adam/.ssh/id_adaptiv";
        extraOptions = {
          AddKeysToAgent = "yes";
          IdentityAgent = "~/.1password/agent.sock";
        };
      };
    };
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
