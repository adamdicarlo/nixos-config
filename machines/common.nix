{
  inputs,
  lib,
  pkgs,
  ...
}: {
  nix = {
    channel.enable = false;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "@wheel"];
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      dates = "monthly";
      persistent = true;
    };

    # Add each flake input as a registry
    # To make nix3 commands consistent with the flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # Add nixpkgs input to NIX_PATH
    # This lets nix2 commands still use <nixpkgs>
    nixPath = ["nixpkgs=${inputs.nixpkgs.outPath}"];
  };

  boot.kernel.sysctl = {
    # Increase the amount of inotify watchers
    # Note that inotify watches consume 1kB on 64-bit machines.
    "fs.inotify.max_user_watches" = 64 * 1024; # default:  8192
    "fs.inotify.max_user_instances" = 1024; # default:   128
    "fs.inotify.max_queued_events" = 32768; # default: 16384
  };

  # Set limits for systemd units (not systemd itself).
  #
  # From `man 5 systemd-system.conf`:
  # DefaultLimitNOFILE= defaults to 1024:524288.
  systemd.extraConfig = ''
    DefaultLimitNOFILE=8192:524288
  '';

  # Enable networking
  networking.networkmanager.enable = lib.mkDefault true;

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
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # Keyboard key map
  services.xserver = {
    xkb = {
      layout = "us";
      variant = "colemak";
      options = "altwin:swap_lalt_lwin,ctrl:nocaps,shift:both_capslock";
    };
    autoRepeatDelay = 200;
    autoRepeatInterval = 20;
  };

  # Map Caps Lock to Ctrl (when held), Esc (when tapped)
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

  programs.nh = {
    enable = true;
    flake = "/home/adam/nixos-config";
  };
  programs.zsh.enable = true;

  services.fstrim.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      AllowAgentForwarding = true;
    };
  };

  # Don't ask for password quite as often
  security.sudo.extraConfig = ''
    Defaults        timestamp_timeout=120
  '';

  users.users.adam = {
    isNormalUser = true;
    description = "Adam DiCarlo";
    extraGroups = ["docker" "libvirtd" "networkmanager" "video" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHw1DBIi3+PCiDnWkPohhHFVKqnAcKzUUezulxxywGHa adam@bikko.org"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbs7eDyOmFy3rZV4zCI6Pz+5srASislwVs36/XcM4sq adam@bikko.org"
    ];
    packages = [];
    shell = pkgs.zsh;
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
    gawk
    gcc
    gnumake
    gnupg
    gnused
    gnutar
    httpie
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
    nh # nix CLI helper: https://github.com/viperML/nh
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
  environment.pathsToLink = ["/share/zsh"];
}
