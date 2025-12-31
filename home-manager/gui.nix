{
  config,
  hostname,
  inputs,
  pkgs,
  lib,
  ...
}: let
  # q-zandronum = pkgs.callPackage (import ./modules/q-zandronum) {};
  isPersonalMachine = hostname == "carbo" || hostname == "echo";
in {
  imports = [
    ./modules/bambu-studio.nix
  ];

  bambuStudio.enable = isPersonalMachine;

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

  # gtk = {
  #   enable = true;
  #   theme = {
  #     package = pkgs.flat-remix-gtk;
  #     name = "Flat-Remix-GTK-Grey-Darkest";
  #   };
  #   iconTheme = {
  #     package = pkgs.libsForQt5.breeze-icons;
  #     name = "breeze-dark";
  #   };
  #   font = {
  #     name = "Sans";
  #     size = 11;
  #   };
  # };

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
      (inputs.zen-browser.packages."${system}".default)

      kitty
      kitty-img
      kitty-themes

      # Wayland, GUI stuff
      cliphist
      dragon-drop
      drm_info
      gst_all_1.gst-vaapi
      hyprpicker
      imv
      libappindicator-gtk3
      libnotify
      playerctl
      slurp
      swappy
      wev
      wf-recorder
      wl-clipboard
      wl-gammarelay-rs
      wlsunset
      wshowkeys
      wtype

      # cosmic
      cosmic-ext-applet-minimon

      # productivity
      (vivaldi.overrideAttrs (_oldAttrs: {
        inherit vivaldi-ffmpeg-codecs;
      }))

      evince
      gimp3
      glow # markdown previewer in terminal
      sushi
      ianny
      meld

      onlyoffice-desktopeditors
      opensnitch-ui
      discord
      slack
      zoom-us
    ]
    ++ (lib.lists.optionals isPersonalMachine [
      chromium
      doomseeker
      doomretro
      gzdoom
      lgogdownloader
      # zandronum-alpha
      # q-zandronum

      freecad-wayland
    ]);

  services.cliphist = {
    enable = true;
    extraOptions = [
      "-max-items"
      "5000"
    ];
  };

  services.nextcloud-client = {
    enable = isPersonalMachine;
    startInBackground = true;
  };

  services.wlsunset = {
    enable = false;
    temperature = {
      day = 4000;
      night = 2800;
    };
    latitude = "45.6";
    longitude = "-122.7";
  };

  services.udiskie = {
    enable = true;
    settings = {
      program_options.file_manager = pkgs.cosmic-files;
      notifications.timeout = 3;
    };
  };

  programs.kitty = {
    enable = true;
    themeFile = "Dracula";
    font = {
      package = pkgs.nerd-fonts.fira-code;
      name = "FiraCode/FiraCode Nerd Font Mono";
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
}
