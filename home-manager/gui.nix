{
  config,
  pkgs,
  ...
}: let
  wallpaper = ./wallpaper/pexels-andy-vu-3484061.jpg;
in {
  imports = [
    ./modules/tridactyl.nix
    ./modules/waybar.nix
  ];

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
    wbg
    wdisplays
    wev
    wf-recorder
    wl-clipboard
    wl-gammarelay-rs
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
        timeout = 930;
        command = "${pkgs.sway}/bin/swaymsg output * power off";
        resumeCommand = "${pkgs.sway}/bin/swaymsg output * power on";
      }
      {
        timeout = 935;
        command = "${pkgs.systemd}/bin/systemctl suspend";
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
      image = "${wallpaper}";
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
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
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
        PasswordManagerEnabled = false;
        UserMessaging = {
          SkipOnboarding = true;
          ExtensionRecommendations = false;
        };
      };
    };
    # nativeMessagingHosts.ff2mpv = true;
    # nativeMessagingHosts.tridactyl = true;
    nativeMessagingHosts = [
      pkgs.ff2mpv
      pkgs.tridactyl-native
    ];
    profiles.default = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
        decentraleyes
        don-t-fuck-with-paste
        dracula-dark-colorscheme
        facebook-container
        ff2mpv
        tree-style-tab
        tridactyl
        ublock-origin
        umatrix
      ];
      search = {
        engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@np"];
          };
          "Nix Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@no"];
          };
          Bing.metaData.hidden = true;
          Google.metaData.alias = "@g";
        };
        force = true;
        order = ["DuckDuckGo" "Google"];
      };
      settings = {
        "app.shield.optoutstudies.enabled" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.contentblocking.category" = "custom";
        "browser.download.dir" = "${config.home.homeDirectory}/Downloads";
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
        "gfx.webrender.all" = true;
        "gfx.webrender.enabled" = true;
        "layers.acceleration.force-enabled" = true;
        "network.cookie.cookieBehavior" = 1;
        "privacy.annotate_channels.strict_list.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "security.identityblock.show_extended_validation" = true;
        "svg.context-properties.content.enabled" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "toolkit.telemetry.cachedClientID" = "c0ffeec0-ffee-c0ff-eec0-ffeec0ffeec0";
        "userChrome.Tabs.Option6.Enabled" = true;
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

      floating = {
        border = 2;
        titlebar = true;
      };

      output = {
        "*" = {
          bg = "${wallpaper} fill";
        };
      };

      window = {
        commands = [
          {
            command = "floating enable";
            criteria = {
              app_id = "(?i)(?:pavucontrol|nm-connection-editor|gsimplecal|galculator)";
            };
          }
          {
            command = "border normal 2, titlebar_padding 24 16";
            criteria = {
              class = "(?i)(?:1Password)";
            };
          }
        ];
        border = 2;
        hideEdgeBorders = "smart";
        titlebar = false;
      };
    };
    extraConfig = ''
      set $laptop eDP-1
      bindswitch --reload --locked lid:on output $laptop disable
      bindswitch --reload --locked lid:off output $laptop enable
      popup_during_fullscreen smart
      titlebar_padding 12 8
      title_align center

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
  systemd.user.services.polkit-mate = {
    Unit = {
      Description = "Graphical Polkit authentication agent";
      PartOf = ["sway-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1";
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
