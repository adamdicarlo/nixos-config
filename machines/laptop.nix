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
    BROWSER = "zen";
    # "Do not set GDK_BACKEND=wayland globally. This is known to break apps."
    # GDK_BACKEND = "wayland";
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
      libva-vdpau-driver
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

  services.flatpak.enable = true;
  system.userActivationScripts.ensureFlatHub = ''
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  '';

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

  services.ddccontrol = {
    enable = true;
  };

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
    mesa-demos
    vulkan-tools
    xdg-utils

    libsForQt5.qt5.qtwayland
    pavucontrol
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

  # For Wayle
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

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

  # https://codeberg.org/kidsan/nixos-config/src/branch/main/nixos/modules/xdg.nix
  systemd.user.services.xdg-desktop-portal-wlr.environment = {
    BEMENU_OPTS = "-H 30 --tb '#6272a4' --tf '#f8f8f2' --fb '#282a36' --ff '#f8f8f2' --nb '#282a36' --nf '#6272a4' --hb '#44475a' --hf '#50fa7b' --sb '#44475a' --sf '#50fa7b' --scb '#282a36' --scf '#ff79c6'";
  };
  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    wlr = {
      enable = true;
      settings = let
        grep = lib.getExe pkgs.gnugrep;
        wayle = lib.getExe' pkgs.wayle "wayle";
      in {
        screencast = {
          exec_before = "${pkgs.writeShellScript "wayle-dnd-on" ''
            notify-send "Wayle dnd on!"
            ${wayle} idle on
            if ${wayle} notify status | ${grep} -q 'Disturb: disabled'; then
              ${wayle} notify dnd
            fi
          ''}";
          exec_after = "${pkgs.writeShellScript "wayle-dnd-off" ''
            ${wayle} idle off
            if ${wayle} notify status | ${grep} -q 'Disturb: enabled'; then
              ${wayle} notify dnd
            fi
          ''}";
          chooser_type = "dmenu";
          chooser_cmd = lib.getExe pkgs.bemenu;
        };
      };
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
    packages = with pkgs; [
      cantarell-fonts
      dejavu_fonts
      dina-font
      fira-code
      fira-code-symbols
      font-awesome
      font-awesome_5
      freefont_ttf
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
      proggyfonts
      twemoji-color-font
      twitter-color-emoji
      unifont
      unifont_upper
      vollkorn
    ];
  };
}
