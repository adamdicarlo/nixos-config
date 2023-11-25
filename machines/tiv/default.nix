# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  lib,
  pkgs,
  ...
}: {
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["adam"];
    };
    package = pkgs.nixFlakes;
  };

  imports = [./hardware.nix];

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

  services.xserver.videoDrivers = ["nvidia"];
  # boot.initrd.kernelModules = ["nvidia"];
  # boot.extraModulePackages = [config.boot.kernelPackages.nvidia_x11];

  # https://nixos.wiki/wiki/Nvidia#Installing_Nvidia_Drivers_on_NixOS
  hardware.nvidia = {
    modesetting.enable = true;

    # This fixes suspend issues with Hyprland.
    powerManagement.enable = true;
    powerManagement.finegrained = false;

    # Whether to use Nvidia's "open source" driver. Not to be confused with Nouveau
    # open = false;
    nvidiaSettings = true;

    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    forceFullCompositionPipeline = true;
  };
  hardware.system76.enableAll = true;
  services.system76-scheduler.enable = true;

  specialisation = {
    # on the go
    OTG.configuration = {
      boot.initrd.kernelModules = ["nvidia"];
      boot.extraModulePackages = [config.boot.kernelPackages.nvidia_x11];
      system.nixos.tags = ["OTG"];
      services.xserver.videoDrivers = ["nvidia"];
      hardware.nvidia = {
        prime = {
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
        modesetting.enable = true;
        powerManagement.finegrained = lib.mkForce true;
        prime.offload.enable = lib.mkForce true;
        prime.offload.enableOffloadCmd = lib.mkForce true;
        prime.sync.enable = lib.mkForce false;
      };
    };
  };

  # Bootloader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 4;
  };
  boot.kernelParams = [
    "actkbd.softrepeat=1"
  ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."luks-89774725-33d7-4569-98ca-969947979248".device = "/dev/disk/by-uuid/89774725-33d7-4569-98ca-969947979248";

  #  boot.blacklistedKernelModules = [
  #    "amd76x_edac" "asus_acpi" "ath_pci" "aty128fb" "atyfb" "bcm43xx" "cirrusfb" "cyber2000fb" "cyblafb" "de4x5" "dv1394" "eepro100" "eth1394" "evbug" "garmin_gps" "gx1fb" "hgafb" "i2c_nvidia_gpu" "i810fb" "intelfb" "kyrofb" "lxfb" "matroxfb_base" "microcode" "neofb" "nvidiafb" "ohci1394" "pcspkr" "pm2fb" "prism54" "psmouse" "radeonfb" "raw1394" "rivafb" "s1d13xxxfb" "savagefb" "sbp2" "sisfb" "snd_intel8x0m" "snd_pcsp" "sstfb" "tdfxfb" "tridentfb" "udlfb" "usbkbd" "usbmouse" "vfb" "viafb" "video1394" "vt8623fb"
  #  ];

  virtualisation.docker = {
    enable = true;
  };

  networking.hostName = "tiv";

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver = {
    dpi = 96;
  };

  # Keyboard
  console.keyMap = "colemak";
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "colemak";
  services.xserver.xkbOptions = "altwin:swap_lalt_lwin,ctrl:nocaps,shift:both_capslock";
  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 20;
  services.interception-tools = {
    enable = true;
    udevmonConfig = let
      intercept = "${pkgs.interception-tools}/bin/intercept";
      uinput = "${pkgs.interception-tools}/bin/uinput";
      caps2esc = "${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc";
    in ''
      - JOB: "${intercept} -g $DEVNODE | ${caps2esc} | ${uinput} -d $DEVNODE"
        DEVICE:
          NAME: "AT Translated Set 2 (k|K)eyboard.*"
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    '';
  };

  services.fstrim.enable = true;

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

  # services.xserver.enable = true;
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.displayManager.sddm.wayland.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.adam = {
    isNormalUser = true;
    description = "Adam DiCarlo";
    extraGroups = ["docker" "networkmanager" "video" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHw1DBIi3+PCiDnWkPohhHFVKqnAcKzUUezulxxywGHa adam@bikko.org"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbs7eDyOmFy3rZV4zCI6Pz+5srASislwVs36/XcM4sq adam@bikko.org"
    ];
    packages = with pkgs; [
      firefox
    ];
    shell = pkgs.zsh;
    uid = 1000;
  };
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Flakes use Git to pull dependencies from data sources, so Git must be installed first
    git

    # Nix
    cachix

    acpi
    brightnessctl
    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring
    curl
    dnsutils # `dig` + `nslookup`
    file
    fish
    gawk
    gcc
    gnumake
    gnupg
    gnused
    gnutar
    ipcalc # calculator for IPv4/v6 addresses
    iperf3
    killall
    ldns # replacement of `dig`, it provide the command `drill`

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    ethtool
    lm_sensors # for `sensors` command
    mtr # A network diagnostic tool
    neovim
    nmap # A utility for network discovery and security auditing
    lshw
    p7zip
    pciutils # lspci
    socat # replacement of openbsd-netcat
    sysstat
    tree
    unzip
    usbutils # lsusb
    wget
    which
    xz
    zip
    zstd

    catppuccin-sddm-corners
    where-is-my-sddm-theme
    sddm-chili-theme

    vifm-full

    pavucontrol
    libsForQt5.qt5.qtwayland
    qt6.qtwayland
  ];

  environment.pathsToLink = ["/share/zsh"];

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

  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  #
  services.actkbd = let
    # sound.mediaKeys.enable uses amixer, which is fine, but it execs it as
    # root, without XDG_RUNTIME_DIR, so it cannot connect to ALSA.
    volumeStep = "2.5%";
    wpctl = "XDG_RUNTIME_DIR=/run/user/${toString config.users.users.adam.uid} ${pkgs.wireplumber}/bin/wpctl";
  in {
    enable = false;
    bindings = [
      # XF86MonBrightnessUp
      {
        keys = [232];
        events = ["key" "rep"];
        command = "${pkgs.brillo}/bin/brillo -U 5";
      }

      # XF86MonBrightnessDown
      {
        keys = [233];
        events = ["key" "rep"];
        command = "${pkgs.brillo}/bin/brillo -A 5";
      }

      # "Mute" media key
      {
        keys = [113];
        events = ["key"];
        command = "${wpctl} set-mute @DEFAULT_SINK@ toggle";
      }

      # "Lower Volume" media key (XF86AudioLowerVolume)
      {
        keys = [114];
        events = ["key" "rep"];
        command = "${wpctl} set-volume @DEFAULT_SINK@ ${volumeStep}-";
      }

      # "Raise Volume" media key (XF86AudioRaiseVolume)
      {
        keys = [115];
        events = ["key" "rep"];
        command = "${wpctl} set-volume @DEFAULT_SINK@ ${volumeStep}+";
      }

      # "Mic Mute" media key
      {
        keys = [190];
        events = ["key"];
        command = "${wpctl} set-mute @DEFAULT_SOURCE@ toggle";
      }
    ];
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      CPU_MAX_PERF_ON_AC = 80;
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
