{
  config,
  pkgs,
  lib,
  ...
}: let
  extraEnv = {
    #  export CLUTTER_BACKEND=wayland
    #  export GDK_BACKEND=wayland,x11
    #  export QT_QPA_PLATFORM=wayland # wayland;xcb
    #  export WLR_RENDERER=vulkan
    #  export XCURSOR_SIZE=24
    #  export __GL_VRR_ALLOWED=1
    # TODO: don't spam all of these into environment.variables?
    BROWSER =
      if config.networking.hostName == "tiv"
      then "google-chrome-stable"
      else "firefox";
    GDK_BACKEND = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    SDL_VIDEODRIVER = "wayland";
    TERMINAL = "kitty";

    # Ugh: after updating to Sway 1.10, kanshi started crashing, and sway would
    # also crash when trying to set the highest resolution on my DELL
    # ultrawide. I had to switch from WLR_DRM_NO_ATOMIC to WLR_DRM_NO_MODIFIERS
    # WLR_DRM_NO_ATOMIC = "1"; Enabling NO_MODIFIERS seemed to fix sway's mode
    # setting (at least when logging in disconnected, then connecting, and
    # manually setting the mode); kanshi still crashed, but disabling NO_ATOMIC
    # seems to have fixed that.
    WLR_DRM_NO_MODIFIERS = "1";
    XDG_CURRENT_DESKTOP = "sway";
  };
in {
  # Allow brightness control from users in the video group
  hardware.brillo.enable = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiVdpau
    ];
  };

  # https://github.com/NixOS/nixpkgs/issues/143365#issuecomment-1293871094
  security.pam.services.swaylock.text = ''
    # Account management.
    account required pam_unix.so

    # Authentication management.
    auth sufficient pam_unix.so   likeauth try_first_pass
    auth required pam_deny.so

    # Password management.
    password sufficient pam_unix.so nullok sha512

    # Session management.
    session required pam_env.so conffile=/etc/pam/environment readenv=0
    session required pam_unix.so
  '';
  security.polkit = {
    enable = true;
  };

  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  hardware.bluetooth = {
    enable = true;
  };
  services.blueman.enable = true;

  hardware.keyboard.uhk.enable = true;
  users.users.adam.extraGroups = ["input"];

  hardware.logitech.wireless.enable = true;

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };
  programs.virt-manager.enable = true;

  services.displayManager.defaultSession = "sway";
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd}/bin/agreety --cmd ${lib.getExe pkgs.zsh}";
      };
    };
  };
  services.xserver = {
    enable = true;
    dpi = 96;
  };
  services.libinput.enable = true;

  services.fwupd = {
    enable = true;
  };

  services.opensnitch = {
    enable = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    # alsa.enable = true;
    # alsa.support32Bit = true;
    pulse.enable = true;

    # use the example session manager (no others are packaged yet so this is
    # enabled by default, no need to redefine it in your config for now)
    #media-session.enable = true;
    wireplumber.enable = true;
  };

  programs.zsh.enable = true;
  environment.variables = extraEnv;
  environment.sessionVariables = extraEnv;
  environment.pathsToLink = ["/share/zsh"];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    brightnessctl
    firmware-updater
    ffmpeg
    glib
    glmark2
    glxinfo
    vulkan-tools
    xdg-utils

    # fonts
    cantarell-fonts
    dina-font
    fira-code
    fira-code-symbols
    font-awesome
    gyre-fonts
    inter
    iosevka
    jetbrains-mono
    joypixels
    liberation_ttf
    monaspace # "texture healing"?
    mplus-outline-fonts.githubRelease
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.fira-mono
    nerd-fonts.monaspace
    nerd-fonts.sauce-code-pro
    nerd-fonts.symbols-only
    nerd-fonts.ubuntu
    nerd-fonts.ubuntu-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji # a good fallback font
    noto-fonts-emoji
    proggyfonts
    twemoji-color-font
    twitter-color-emoji
    unifont
    unifont_upper
    vollkorn

    libsForQt5.qt5.qtwayland
    pavucontrol
    swayosd
    qt6.qtwayland

    qemu_kvm

    uhk-agent
  ];

  programs.dconf.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  services.dbus.enable = true;

  # This was an attempt to get swayosd-libinput-backend to work properly. The
  # service would start (though only when manually via systemctl), and dbus
  # messages would be generated when pressing volume keys, but nothing
  # happened, and the message send destination was null (problem or red
  # herring?).
  # services.udev.packages = [pkgs.swayosd];
  # services.dbus.packages = [pkgs.swayosd];
  # systemd.packages = [pkgs.swayosd];

  services.tlp = {
    enable = true;
    settings = {
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 85;

      CPU_MAX_PERF_ON_AC = lib.mkDefault 100;
      CPU_MAX_PERF_ON_BAT = lib.mkDefault 80;
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  services.udisks2 = {
    enable = true;
  };

  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      settings = {
        screencast = {
          max_fps = 15;
          chooser_type = "simple";
          chooser_cmd = "${lib.getExe pkgs.slurp} -f %o -or";
        };
      };
    };
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config.preferred = {
      default = "gtk";
      "org.freedesktop.impl.portal.Screencast" = "wlr";
    };
  };

  services.printing = {
    drivers = [pkgs.splix];
  };

  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
      hinting.enable = true;
      defaultFonts = {
        monospace = ["DejaVu Sans Mono" "Noto Mono"];
        serif = ["Vollkorn" "Noto Serif" "Times New Roman"];
        sansSerif = ["Open Sans" "Noto Sans"];
        emoji = [
          "Noto Color Emoji"
          "NotoEmoji Nerd Font Mono"
          "Twitter Color Emoji"
          "JoyPixels"
          "Unifont"
          "Unifont Upper"
        ];
      };
      localConf = ''
        <!-- use a less horrible font substition for pdfs such as https://www.bkent.net/Doc/mdarchiv.pdf -->
        <match target="pattern">
          <test qual="any" name="family"><string>NewCenturySchlbk</string></test>
          <edit name="family" mode="assign" binding="same"><string>TeX Gyre Schola</string></edit>
        </match>
      '';
    };
  };
}
