{
  hostname,
  pkgs,
  lib,
  ...
}: let
  q-zandronum = pkgs.callPackage (import ./modules/q-zandronum) {};
  c = import ../lib/dracula.nix;

  fileManager = pkgs.nautilus;

  isPersonalMachine = hostname == "carbo";
  isWorkMachine = !isPersonalMachine;

  wallpaper =
    if isPersonalMachine
    then ./wallpaper/pexels-andy-vu-3484061.jpg
    else ./wallpaper/pexels-eberhard-grossgasteiger-1062249.jpg;
in {
  imports = [
    ./modules/kanshi.nix
    ./modules/firefox.nix
    ./modules/polkit-mate.nix
    ./modules/swayosd.nix
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
    "Xcursor.size" = 32;
    "Xft.dpi" =
      if isPersonalMachine
      then 192
      else 96;
  };

  home.packages = with pkgs;
    [
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
      nautilus
      sushi
      ianny
      meld
      nerdfonts
      onlyoffice-bin_latest
      opensnitch-ui
      slack
      zoom-us
    ]
    ++ (lib.lists.optionals isPersonalMachine [
      doomseeker
      doomretro
      gzdoom
      lgogdownloader
      zandronum-alpha
      q-zandronum

      bambu-studio
      freecad-wayland
    ]);

  services.cliphist = {
    enable = true;
    extraOptions = [
      "-max-items"
      "5000"
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
    enable = isPersonalMachine;
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

  programs.kitty = {
    enable = true;
    themeFile = "Dracula";
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

  xdg.configFile."wlogout/layout" = {
    text = ''
      {
        "label" : "lock",
        "action" : "swaylock",
        "text" : "Lock"
      } {
        "label" : "hibernate",
        "action" : "systemctl hibernate",
        "text" : "Hibernate"
      } {
        "label" : "logout",
        "action" : "swaymsg exit",
        "text" : "Log out"
      } {
        "label" : "shutdown",
        "action" : "systemctl poweroff",
        "text" : "Shutdown"
      } {
        "label" : "suspend",
        "action" : "systemctl suspend",
        "text" : "Suspend"
      } {
        "label" : "reboot",
        "action" : "systemctl reboot",
        "text" : "Reboot"
      }
    '';
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

      colors = {
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
        # child_border: The border around the view itself.
        #
        focused = {
          border = c.cyan;
          background = c.black;
          text = c.white;
          indicator = c.brightCyan;
          childBorder = c.cyan;
        };
        focusedInactive = {
          border = c.blue;
          background = c.black;
          text = c.gray;
          indicator = c.blue;
          childBorder = c.black;
        };
        unfocused = {
          border = c.blue;
          background = c.black;
          text = c.gray;
          indicator = c.blue;
          childBorder = c.black;
        };
        urgent = {
          border = c.red;
          background = c.black;
          text = c.white;
          indicator = c.red;
          childBorder = c.red;
        };
        background = c.black;
      };

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
        swayosd = lib.getExe' pkgs.swayosd "swayosd-client";
      in
        lib.mkOptionDefault {
          "${modifier}+Shift+e" = "exec ${lib.getExe pkgs.wlogout} --protocol layer-shell";
          "${modifier}+s" = "exec ~/bin/grim-swappy.sh";
          "${modifier}+Shift+s" = "exec ~/bin/wf-record-area.sh";
          "${modifier}+Shift+f" = "exec ${lib.getExe fileManager}";
          "${modifier}+y" = "exec pkill wofi || cliphist list | wofi -dmenu | cliphist decode | wl-copy";
          "${modifier}+m" = "exec pkill wofi || wofi-emoji";

          "--release Caps_Lock" = "exec ${swayosd} --caps-lock";
          "XF86AudioRaiseVolume" = "exec ${swayosd} --output-volume raise";
          "XF86AudioLowerVolume" = "exec ${swayosd} --output-volume lower";
          "XF86AudioMute" = "exec ${swayosd} --output-volume mute-toggle";
          "XF86MonBrightnessUp" = "exec ${swayosd} --brightness raise";
          "XF86MonBrightnessDown" = "exec ${swayosd} --brightness lower";
        };

      startup =
        [
          {
            # Always run this when Sway starts, so that GUI services like
            # portals and polkit agent don't break!
            command = "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK";
            always = true;
          }
        ]
        ++ [{command = lib.getExe pkgs.opensnitch-ui;}]
        ++ (lib.optionals isPersonalMachine [{command = lib.getExe pkgs.nextcloud-client;}])
        ++ (lib.optionals isWorkMachine [{command = "1password --silent";}]);

      terminal = lib.getExe pkgs.kitty;
      menu = lib.getExe pkgs.fuzzel;

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
}
