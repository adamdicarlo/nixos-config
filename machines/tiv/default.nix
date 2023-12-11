# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  lib,
  pkgs,
  ...
}: let
  extraEnv = {
    GDK_BACKEND = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    WLR_DRM_NO_ATOMIC = "1";
    XDG_CURRENT_DESKTOP = "sway";
    # GBM_BACKEND = "nvidia-drm";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # __GL_GSYNC_ALLOWED = "0";
    # __GL_VRR_ALLOWED = "0";
  };
in {
  imports = [./hardware.nix ../common.nix];

  # Allow brightness control from users in the video group
  hardware.brillo.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
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
  security.polkit.enable = true;
  services.logind.lidSwitchExternalPower = "ignore";
  hardware.logitech.wireless.enable = true;

  # boot.initrd.kernelModules = ["nouveau"];
  # services.xserver.videoDrivers = ["nouveau"];

  hardware.system76.enableAll = true;
  services.system76-scheduler.enable = true;

  # Bootloader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 4;
  };
  boot.kernelParams = [
    "blacklist=nvidia"
  ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."luks-89774725-33d7-4569-98ca-969947979248".device = "/dev/disk/by-uuid/89774725-33d7-4569-98ca-969947979248";

  boot.blacklistedKernelModules = ["nvidia"];
  networking.hostName = "tiv";

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };
  programs.virt-manager.enable = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  services.xserver = {
    enable = true;
    displayManager.defaultSession = "sway";
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    dpi = 96;
    libinput.enable = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
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

  programs.fish.enable = true;
  programs.zsh.enable = true;
  environment.variables = extraEnv;
  environment.sessionVariables = extraEnv;
  environment.pathsToLink = ["/share/zsh"];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    brightnessctl
    glib
    xdg-utils
    glxinfo
    vulkan-tools
    glmark2

    catppuccin-sddm-corners
    where-is-my-sddm-theme
    sddm-chili-theme

    pavucontrol
    libsForQt5.qt5.qtwayland
    qt6.qtwayland

    qemu_kvm
  ];

  # Some programs need SUID wrappers, can be configured further or are
  #
  programs._1password = {
    enable = true;
  };
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["adam"];
  };

  programs.dconf.enable = true;

  programs.sway = {
    enable = true;
    extraOptions = [
      "--unsupported-gpu"
    ];
    # Render via the iGPU (intel device) only! (Is --unsupported-gpu actually necessary?)
    extraSessionCommands = ''
      WLR_DRM_DEVICES="$(if test -d /sys/class/drm/card1/card1-eDP-1; then echo /dev/dri/card1; else echo /dev/dri/card0; fi)"
      export WLR_DRM_DEVICES
    '';
    wrapperFeatures.gtk = true;
  };

  # List services that you want to enable:
  services.actkbd = {
    enable = false;
    # Don't use sound.mediaKeys.enable, since it execs as root (without
    # XDG_RUNTIME_DIR), and thus cannot connect to ALSA.
    # guiEnv = "XDG_RUNTIME_DIR=/run/user/${toString config.users.users.adam.uid}";
    # wpctl = "${guiEnv} ${pkgs.wireplumber}/bin/wpctl";
    # volumeStep = "2.5%";
    # brillo = "${pkgs.brillo}/bin/brillo";
    # Shift_L = 42;
    # XF86MonBrightnessUp = 232;
    # XF86MonBrightnessDown = 233;
    # XF86AudioMute = 113;
    # XF86AudioMicMute = 190;
    # XF86AudioLowerVolume = 114;
    # XF86AudioRaiseVolume = 115;
    # bindings = builtins.concatLists [
    #   (onKey XF86MonBrightnessUp noRepeat "${brillo} -A 5")
    #   (onKey XF86MonBrightnessDown noRepeat "${brillo} -U 5")
    #   (onKey XF86AudioMute noRepeat "${wpctl} set-mute @DEFAULT_SINK@ toggle")
    #   (onKey XF86AudioMicMute noRepeat "${wpctl} set-mute @DEFAULT_SOURCE@ toggle")
    #   (onKey XF86AudioLowerVolume noRepeat "${wpctl} set-volume @DEFAULT_SINK@ ${volumeStep}-")
    #   (onKey XF86AudioRaiseVolume noRepeat "${wpctl} set-volume @DEFAULT_SINK@ ${volumeStep}+")
    #   (onKey [Shift_L XF86AudioMute] noRepeat "${wpctl} set-mute @DEFAULT_SOURCE@ toggle")
    #   (onKey [Shift_L XF86AudioLowerVolume] noRepeat "${wpctl} set-volume @DEFAULT_SOURCE@ ${volumeStep}-")
    #   (onKey [Shift_L XF86AudioRaiseVolume] noRepeat "${wpctl} set-volume @DEFAULT_SOURCE@ ${volumeStep}+")
    # ];
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 85;

      CPU_MAX_PERF_ON_AC = 85;
      CPU_MAX_PERF_ON_BAT = 60;
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

  # throttled doesn't support i9-13900HX.
  # undervolting seems to be locked in firmware.
  services.undervolt = {
    enable = false;
    tempBat = 75;
    tempAc = 80;
    p2.limit = 90;
    p2.window = 1;
  };

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
