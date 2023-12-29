{
  inputs,
  lib,
  pkgs,
  ...
}: {
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes" "repl-flake"];
      trusted-users = ["root" "@wheel"];
      warn-dirty = false;
      flake-registry = "";
    };
    gc = {
      automatic = true;
      dates = "weekly";
    };

    # Add each flake input as a registry
    # To make nix3 commands consistent with the flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # Add nixpkgs input to NIX_PATH
    # This lets nix2 commands still use <nixpkgs>
    nixPath = ["nixpkgs=${inputs.nixpkgs.outPath}"];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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

  # Console
  console.font = "Lat2-Terminus16";

  # Keyboard key map
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
            EV_KEY: [[KEY_CAPSLOCK, KEY_ESC]]
    '';
  };

  programs.fish.enable = true;

  services.fstrim.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  users.users.adam = {
    isNormalUser = true;
    description = "Adam DiCarlo";
    extraGroups = ["docker" "libvirtd" "networkmanager" "video" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHw1DBIi3+PCiDnWkPohhHFVKqnAcKzUUezulxxywGHa adam@bikko.org"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbs7eDyOmFy3rZV4zCI6Pz+5srASislwVs36/XcM4sq adam@bikko.org"
    ];
    packages = [];
    shell = pkgs.fish;
    uid = 1000;
  };

  environment.systemPackages = with pkgs; [
    # Flakes use Git to pull dependencies from data sources, so Git must be installed first
    git

    # Nix
    inputs.agenix.packages.x86_64-linux.default
    cachix
    home-manager

    acpi
    age
    btop # replacement of htop/nmon
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
    iftop # network monitoring
    iotop # io monitoring
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
    gtop
    lm_sensors # for `sensors` command
    lshw
    mtr # A network diagnostic tool
    neovim
    nmap # A utility for network discovery and security auditing
    p7zip
    pciutils # lspci
    socat # replacement of openbsd-netcat
    sysstat
    tree
    unzip
    usbutils # lsusb
    vifm-full
    wget
    which
    xz
    zip
    zstd
  ];
}
