{
  config,
  hostname,
  inputs,
  pkgs,
  lib,
  ...
}: let
  c = import ../lib/dracula.nix;

  fileManager = pkgs.gnome.nautilus;

  firefox-addons =
    import inputs.firefox-addons {inherit (pkgs) fetchurl lib stdenv;};

  isPersonalMachine = hostname == "carbo";
  isWorkMachine = !isPersonalMachine;

  wallpaper =
    if isPersonalMachine
    then ./wallpaper/pexels-andy-vu-3484061.jpg
    else ./wallpaper/pexels-eberhard-grossgasteiger-1062249.jpg;
in {
  imports = [
    ./modules/tridactyl.nix
    ./modules/waybar.nix
  ];

  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.quintom-cursor-theme;
    name = "Quintom_Ink";
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
    chayang
    cliphist
    drm_info
    fuzzel
    grim
    gst_all_1.gst-vaapi
    hyprpicker
    imv
    libappindicator-gtk3
    libnotify
    mako
    networkmanagerapplet
    nwg-displays
    playerctl
    slurp
    swappy
    swaybg
    swayest-workstyle
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
    (google-chrome.override {commandLineArgs = "--ozone-platform=wayland";})
    evince
    font-awesome
    gimp-with-plugins
    glow # markdown previewer in terminal
    gnome.nautilus
    gnome.sushi
    meld
    nerdfonts
    onlyoffice-bin_latest
    opensnitch-ui
    slack
    zoom-us
  ];

  services.cliphist = {
    enable = true;
    extraOptions = [
      "-max-items"
      "5000"
    ];
  };

  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "dell-ultrawide";
        profile.outputs = [
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
      }
      {
        profile.name = "lg-ultrawide";
        profile.outputs = [
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
      }
      {
        profile.name = "x1c7-undocked";
        profile.outputs = [
          {
            criteria = "Unknown 0x07C8 0x00000000";
            status = "enable";
            mode = "3840x2160@60Hz";
            position = "0,0";
            scale = 2.0;
          }
        ];
      }
      {
        profile.name = "addw3-undocked";
        profile.outputs = [
          {
            criteria = "BOE 0x08B3";
            status = "enable";
            mode = "1920x1080@144Hz";
            position = "0,0";
            scale = 1.0;
          }
        ];
      }
    ];
  };

  services.mako = {
    enable = true;
    backgroundColor = "${c.blue}E0";
    borderColor = c.black;
    borderRadius = 8;
    borderSize = 2;
    font = "FiraCode Nerd Font Mono 10";
    height = 120;
    maxVisible = 6;
    padding = "12";
    width = 360;
    textColor = c.white;

    extraConfig = ''
      [urgency=critical]
      background-color=${c.purple}E0

      [app-name=clamav-alert]
      background-color=${c.red}
      width=600
      height=240
      padding=24
      font=FiraCode Nerd Font Mono 15
      on-notify=exec ${lib.getExe pkgs.kitty} -o window_padding_width=12 --class=floating journalctl -eu clamav-daemon.service
    '';
  };
  services.network-manager-applet.enable = true;

  services.nextcloud-client = {
    enable = hostname == isPersonalMachine;
    startInBackground = true;
  };

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 900;
        command = "${lib.getExe pkgs.chayang} -d 10 && ${pkgs.sway}/bin/swaymsg output * power off";
        resumeCommand = "${pkgs.sway}/bin/swaymsg output * power on";
      }
      {
        timeout = 915;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "${lib.getExe pkgs.swaylock} -f";
      }
    ];
  };

  # Requires services.udisks2 in system config.
  services.udiskie = {
    enable = true;
    settings = {
      program_options.file_manager = fileManager;
      notifications.timeout = 3;
    };
  };

  programs.swaylock = {
    enable = true;
    settings = let
      transparent = "00000000";
    in {
      bs-hl-color = "${c.u.cyan}BB";
      caps-lock-bs-hl-color = "${c.u.brightYellow}BB";
      caps-lock-key-hl-color = "${c.u.brightYellow}BB";
      color = c.u.blue;
      font = "Inter";
      ignore-empty-password = true;
      image = "${wallpaper}";
      indicator-caps-lock = true;
      indicator-radius = "200";
      indicator-thickness = "28";

      inside-caps-lock-color = "${c.u.background}BB";
      inside-clear-color = "${c.u.background}BB";
      inside-color = "${c.u.background}BB";
      inside-ver-color = "${c.u.background}DD";
      inside-wrong-color = "${c.u.background}DD";

      key-hl-color = c.u.green;

      line-caps-lock-color = transparent;
      line-clear-color = transparent;
      line-color = transparent;
      line-ver-color = transparent;
      line-wrong-color = transparent;

      ring-caps-lock-color = "${c.u.brightYellow}BB";
      ring-clear-color = "${c.u.cyan}BB";
      ring-color = "${c.u.purple}BB";
      ring-ver-color = "${c.u.purple}BB";
      ring-wrong-color = "${c.u.red}BB";

      separator-color = transparent;
      show-failed-attempts = true;
      show-keyboard-layout = false;

      text-caps-lock-color = c.u.white;
      text-clear-color = c.u.white;
      text-color = c.u.white;
      text-ver-color = c.u.white;
      text-wrong-color = c.u.white;
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
      extensions = with firefox-addons; [
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
      scrollback_lines = 30000;
      sync_to_monitor = false;
      visual_bell_duration = "0.2";
      window_padding_width = 4;
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
      keybindings = let
        brillo = "${lib.getExe pkgs.brillo}";
        wpctl = "${pkgs.wireplumber}/bin/wpctl";
      in
        lib.mkOptionDefault {
          "${modifier}+Shift+e" = "exec wlogout --protocol layer-shell";
          "${modifier}+s" = "exec ~/bin/grim-swappy.sh";
          "${modifier}+Shift+s" = "exec ~/bin/wf-record-area.sh";
          "${modifier}+Shift+f" = "exec ${lib.getExe fileManager}";
          "${modifier}+y" = "exec cliphist list | wofi -dmenu | cliphist decode | wl-copy";
          "${modifier}+m" = "exec pkill wofi-emoji || wofi-emoji";

          "XF86AudioLowerVolume" = "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute" = "exec ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioRaiseVolume" = "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+";

          "XF86MonBrightnessDown" = "exec ${brillo} -q -U 5%";
          "XF86MonBrightnessUp" = "exec ${brillo} -q -A 5%";
        };

      startup =
        (lib.optionals isPersonalMachine [{command = lib.getExe pkgs.nextcloud-client;}])
        ++ (lib.optionals isWorkMachine [{command = "1password --silent";}]);

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
              app_id = "floating";
            };
          }
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

      #
      # man 5 sway
      #
      # client.<class> <border> <background> <text> [<indicator> [<child_border>]]
      #
      # border: The border around the title bar.
      # background: The background of the title bar.
      # text: The text color of the title bar.
      # indicator: The color used to indicate where a new view will open. In a
      #   tiled container, this would paint the right border of the current
      #   view if a new view would be opened to the right.
      #
      # child_border: The border around the view itself.
      #
      client.focused          ${c.cyan}  ${c.black} ${c.white} ${c.brightCyan} ${c.cyan}
      client.focused_inactive ${c.blue}  ${c.black} ${c.gray}  ${c.blue}       ${c.black}
      client.unfocused        ${c.blue}  ${c.black} ${c.gray}  ${c.blue}       ${c.black}
      client.urgent           ${c.red}   ${c.black} ${c.white} ${c.red}        ${c.red}
      client.background       ${c.black}
    '';

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
