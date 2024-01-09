{pkgs, ...}: {
  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Amber";
    size = 32;
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
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

  home.file."Pictures/wallpaper" = {
    source = ./wallpaper;
    recursive = true;
  };

  # set cursor size and dpi
  xresources.properties = {
    "Xcursor.size" = 24;
    "Xft.dpi" = 96;
  };

  home.packages = with pkgs; [
    kitty
    kitty-img
    kitty-themes

    # Wayland, GUI stuff
    cliphist
    drm_info
    fuzzel
    grim
    gst_all_1.gst-vaapi
    hyprpicker
    imv
    kooha
    libappindicator-gtk3
    libnotify
    mako
    networkmanagerapplet
    nwg-displays
    playerctl
    slurp
    swappy
    swaybg
    swayidle
    swaylock
    swaynag-battery
    udiskie
    waybar
    wbg
    wdisplays
    wev
    wf-recorder
    wl-clipboard
    wl-gammarelay-rs
    wlay
    wlogout
    wlsunset
    wob
    wofi
    wofi-emoji
    wshowkeys
    wtype
    xdragon

    # productivity
    font-awesome
    glow # markdown previewer in terminal
    nerdfonts

    dolphin
    google-chrome
    meld
    slack
  ];

  services.cliphist = {
    enable = true;
  };

  services.kanshi = {
    enable = true;
    profiles = {
      dell-ultrawide = {
        outputs = [
          {
            criteria = "Dell Inc. DELL U3821DW HH7YZ63";
            status = "enable";
            mode = "3840x1600@60Hz";
            position = "0,0";
            scale = 1.0;
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
        ];
      };

      lg-ultrawide = {
        outputs = [
          {
            criteria = "Goldstar Company Ltd LG HDR WQHD 0x0000B6E2";
            status = "enable";
            mode = "3440x1440@60Hz";
            position = "0,0";
            scale = 1.0;
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
        ];
      };

      x1c7-undocked = {
        outputs = [
          {
            criteria = "Unknown 0x07C8 0x00000000";
            status = "enable";
            mode = "3840x2160@60Hz";
            position = "0,0";
            scale = 2.0;
          }
        ];
      };

      addw3-undocked = {
        outputs = [
          {
            criteria = "BOE 0x08B3";
            status = "enable";
            mode = "1920x1080@144Hz";
            position = "0,0";
            scale = 1.0;
          }
        ];
      };
    };
  };

  services.mako.enable = true;
  services.network-manager-applet.enable = true;

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 900;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        timeout = 915;
        command = "${pkgs.sway}/bin/swaymsg output * power off";
        resumeCommand = "${pkgs.sway}/bin/swaymsg output * power on";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
    ];
  };

  # Requires services.udisks2 in system config.
  services.udiskie = {
    enable = true;
    settings = {
      program_options.file_manager = "${pkgs.dolphin}/bin/dolphin";
      notifications.timeout = 3;
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      bs-hl-color = "ee2e24ff";
      caps-lock-bs-hl-color = "ee2e24ff";
      caps-lock-key-hl-color = "ffd204ff";
      color = "22d0d2ff";
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

      line-caps-lock-color = "009ddcff";
      line-clear-color = "ffd204ff";
      line-color = "009ddc00";
      line-ver-color = "d9d8d8ff";
      line-wrong-color = "ee2e24ff";

      ring-caps-lock-color = "231f20d9";
      ring-clear-color = "231f20d9";
      ring-color = "231f20d9";
      ring-ver-color = "231f20d9";
      ring-wrong-color = "231f20d9";

      separator-color = "231f20dd";
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
    systemd.enable = true;
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
          "sway/workspaces"
          # "custom/scratchpad-indicator"
          "sway/mode"
          "wlr/taskbar"
        ];
        "modules-center" = ["sway/window"];
        "modules-right" = [
          "cpu"
          "temperature#cpu"
          "temperature#gpu"
          "idle_inhibitor"
          "backlight"
          "pulseaudio"
          "privacy"
          # "bluetooth"
          "network"
          "battery"
          "tray"
          "clock"
        ];
        # Modules configuration
        "sway/workspaces" = {
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            "1" = "<span color=\"#D8DEE9\">  </span>";
            "2" = "<span color=\"#88C0D0\">  </span>";
            "3" = "<span color=\"#D8DEE9\">  </span>";
            "4" = "<span color=\"#A3BE8C\">  </span>";
            urgent = "";
            focused = "";
            default = "";
          };
        };
        "sway/mode" = {
          tooltip = false;
        };
        "backlight" = {
          device = "acpi_video0";
        };
        bluetooth = {
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
            "activated" = "";
            "deactivated" = " ";
          };
          tooltip = true;
        };
        "tray" = {
          #"icon-size = 11;
          spacing = 6;
        };
        "clock" = {
          "format" = "  {:%r     %b %e}";
          "tooltip-format" = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
          "today-format" = "<b>{}</b>";
          "on-click" = "";
        };
        "cpu" = {
          "interval" = "1";
          "format" = "  {max_frequency}GHz <span color=\"darkgray\">| {usage}%</span>";
          "max-length" = 13;
          "min-length" = 13;
          "on-click" = "${pkgs.sway}/bin/swaymsg exec \"${pkgs.kitty}/bin/kitty -e btop\"";
          "tooltip" = false;
        };
        "temperature#cpu" = {
          "thermal-zone" = 0;
          "interval" = "2";
          # "hwmon-path" = "/sys/class/hwmon/hwmon3/temp1_input";
          "critical-threshold" = 80;
          "format-critical" = "  {temperatureC}°C";
          "format" = "{icon}  {temperatureC}°C";
          "format-icons" = [""];
          "max-length" = 7;
          "min-length" = 7;
        };
        "temperature#gpu" = {
          thermal-zone = 1;
          interval = "2";
          # "hwmon-path" = "/sys/class/hwmon/hwmon3/temp1_input";
          critical-threshold = 74;
          format-critical = "  {temperatureC}°C";
          format = "{icon}  {temperatureC}°C";
          format-icons = [""];
          max-length = 7;
          min-length = 7;
        };
        network = {
          # "interface" = "wlan0", # (Optional) To force the use of this interface,
          format-wifi = " ";
          format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
          family = "ipv4";
          tooltip-format-wifi = "  {ifname} @ {essid}\nIP: {ipaddr}\nStrength: {signalStrength}%\nFreq: {frequency}MHz\n {bandwidthUpBits}  {bandwidthDownBits}";
          tooltip-format-ethernet = " {ifname}\nIP: {ipaddr}\n {bandwidthUpBits}  {bandwidthDownBits}";
        };
        privacy = {
          icon-spacing = 4;
          icon-size = 18;
          transition-duration = 350;
          modules = [
            {
              type = "screenshare";
              tooltip = true;
              tooltip-icon-size = 24;
            }
            {
              type = "audio-out";
              tooltip = true;
              tooltip-icon-size = 24;
            }
            {
              type = "audio-in";
              tooltip = true;
              tooltip-icon-size = 24;
            }
          ];
        };
        pulseaudio = {
          scroll-step = 2.5; # %, can be a float
          format = "{icon}  {volume}% {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          #"format-source-muted" = "";
          # format-source = "";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = ["" "" ""];
          };
          on-click = "${pkgs.sway}/bin/swaymsg exec \"${pkgs.pavucontrol}/bin/pavucontrol\"";
          on-click-right = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SOURCE@ toggle";
        };
        battery = {
          states = {
            warning = 25;
            critical = 10;
          };
          format = " {icon}   {capacity}% ";
          format-alt = " {time}  {icon}  ";
          format-icons = ["" "" "" "" ""];
          format-time = "{H}:{M}";
          tooltip = false;
          interval = 20;
        };
      };
    };
  };

  services.wlsunset = {
    enable = true;
    temperature = {
      day = 4000;
      night = 2800;
    };
    latitude = "45.6";
    longitude = "-122.7";
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

  programs.mpv = {
    enable = true;
  };

  wayland.windowManager.sway = let
    # Mod1: Alt
    # Mod4: Super
    modifier = "Mod4";
  in {
    enable = true;
    package = null;
    systemd.enable = true;
    config = {
      bars = [];
      fonts = {
        names = ["FiraCode Nerd Font Mono" "FontAwesome6Free"];
        size = 11.0;
      };

      gaps = {
        inner = 4;
        outer = 0;
        smartBorders = "on";
        smartGaps = true;
      };

      input = {
        "type:keyboard" = {
          xkb_layout = "us";
          xkb_variant = "colemak";
          xkb_options = "altwin:swap_lalt_lwin,ctrl:nocaps,shift:both_capslock";
          repeat_delay = "200";
          repeat_rate = "50";
        };
        "type:pointer" = {
          natural_scroll = "enabled";
        };

        "type:touchpad" = {
          tap = "disabled";
          tap_button_map = "lrm";
          drag = "enabled";
          drag_lock = "disabled";
          dwt = "enabled";
          natural_scroll = "enabled";
          middle_emulation = "enabled";
          scroll_method = "two_finger";
        };
      };

      # KEYS
      inherit modifier;
      left = "j";
      right = "l";
      up = "h";
      down = "k";
      keybindings = pkgs.lib.mkOptionDefault {
        "${modifier}+Shift+e" = "exec wlogout --protocol layer-shell";
        "${modifier}+s" = "exec ~/bin/grim-swappy.sh";
        "${modifier}+Shift+s" = "exec ~/bin/wf-record-area.sh";
        "${modifier}+Shift+f" = "exec dolphin";
        "${modifier}+y" = "exec cliphist list | wofi -dmenu | cliphist decode | wl-copy";
        "${modifier}+m" = "exec pkill wofi-emoji || wofi-emoji";
      };

      startup = [
        {command = "1password --silent";}
        # {command = "slack";}
        # {command = "firefox";}
      ];

      terminal = "${pkgs.kitty}/bin/kitty";
      menu = "${pkgs.fuzzel}/bin/fuzzel";

      window = {
        commands = [
          {
            command = "floating enable";
            criteria = {
              app_id = "(?i)(?:pavucontrol|nm-connection-editor|gsimplecal|galculator)";
            };
          }
        ];
        hideEdgeBorders = "smart";
        titlebar = false;
      };
    };
    extraConfig = ''
      set $laptop eDP-1
      bindswitch --reload --locked lid:on output $laptop disable
      bindswitch --reload --locked lid:off output $laptop enable
      popup_during_fullscreen smart

      # XF86Display key on 'tiv' is Alt_L+; (well, Super_L+p before Colemak and swap_lalt_lwin)
      bindsym --no-repeat Mod1+semicolon exec wdisplays
      bindsym --no-repeat --locked Shift+Mod1+semicolon output * enable; output * dpms on
    '';
    #  export BROWSER=google-chrome-stable
    #  export CLUTTER_BACKEND=wayland
    #  export GBM_BACKEND=nvidia-drm
    #  export GDK_BACKEND=wayland,x11
    #  export LIBVA_DRIVER_NAME=nvidia
    #  export NIXOS_OZONE_WL=1
    #  export QT_QPA_PLATFORM=wayland # wayland;xcb
    #  export SDL_VIDEODRIVER=wayland
    #  export TERMINAL=kitty
    #  export WLR_NO_HARDWARE_CURSORS=1
    #  export WLR_RENDERER=vulkan
    #  export XCURSOR_SIZE=24
    #  export __GLX_VENDOR_LIBRARY_NAME=nvidia
    #  export __GL_VRR_ALLOWED=1
    #'';
    swaynag = {
      enable = true;
      settings = {
        "<config>" = {
          edge = "bottom";
          font = "Dina 12";
        };

        green = {
          edge = "top";
          background = "00AA00";
          text = "FFFFFF";
          button-background = "00CC00";
          message-padding = 10;
        };
      };
    };
  };

  # Adapted from https://github.com/Madic-/Sway-DE/blob/master/config/systemd/user/polkit-gnome.service.j2
  systemd.user.services.polkit-gnome = {
    Unit = {
      Description = "Legacy polkit authentication agent for GNOME";
      PartOf = ["sway-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      ExecStop = "kill -2 $MAINPID";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
    Install = {
      WantedBy = ["sway-session.target"];
    };
  };
}
