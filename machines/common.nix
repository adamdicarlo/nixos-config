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

  # Keyboard key map for virtual ttys.
  services.xserver = {
    xkb = {
      layout = "us";
      variant = "colemak";
      options = "altwin:swap_lalt_lwin";
    };
    autoRepeatDelay = 200;
    autoRepeatInterval = 50;
  };

  # Map Caps Lock to Ctrl (when held), Esc (when tapped)
  services.interception-tools = {
    enable = true;
    plugins = [pkgs.interception-tools-plugins.caps2esc];
    udevmonConfig = let
      # udevmon clears PATH before running commands?!
      # https://github.com/NixOS/nixpkgs/issues/126681#issuecomment-1139347209
      mux = "${pkgs.interception-tools}/bin/mux";
      uinput = "${pkgs.interception-tools}/bin/uinput";
      intercept = "${pkgs.interception-tools}/bin/intercept";
      caps2esc = "${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc";

      # Generated via:
      # sudo uinput -p -d /dev/input/by-id/usb-Ultimate_Gadget_Laboratories_UHK_60_v2_0884155970-event-kbd
      virtualKeyboardYAML = builtins.toFile "virtual-kbd.yaml" ''
        NAME: Magic Keyboard
        PRODUCT: 3
        VENDOR: 14248
        BUSTYPE: BUS_USB
        DRIVER_VERSION: 65537
        EVENTS:
          EV_SYN: [SYN_REPORT, SYN_CONFIG, SYN_MT_REPORT, SYN_DROPPED]
          EV_KEY: [KEY_ESC, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0, KEY_MINUS, KEY_EQUAL, KEY_BACKSPACE, KEY_TAB, KEY_Q, KEY_W, KEY_E, KEY_R, KEY_T, KEY_Y, KEY_U, KEY_I, KEY_O, KEY_P, KEY_LEFTBRACE, KEY_RIGHTBRACE, KEY_ENTER, KEY_LEFTCTRL, KEY_A, KEY_S, KEY_D, KEY_F, KEY_G, KEY_H, KEY_J, KEY_K, KEY_L, KEY_SEMICOLON, KEY_APOSTROPHE, KEY_GRAVE, KEY_LEFTSHIFT, KEY_BACKSLASH, KEY_Z, KEY_X, KEY_C, KEY_V, KEY_B, KEY_N, KEY_M, KEY_COMMA, KEY_DOT, KEY_SLASH, KEY_RIGHTSHIFT, KEY_KPASTERISK, KEY_LEFTALT, KEY_SPACE, KEY_CAPSLOCK, KEY_F1, KEY_F2, KEY_F3, KEY_F4, KEY_F5, KEY_F6, KEY_F7, KEY_F8, KEY_F9, KEY_F10, KEY_NUMLOCK, KEY_SCROLLLOCK, KEY_KP7, KEY_KP8, KEY_KP9, KEY_KPMINUS, KEY_KP4, KEY_KP5, KEY_KP6, KEY_KPPLUS, KEY_KP1, KEY_KP2, KEY_KP3, KEY_KP0, KEY_KPDOT, KEY_ZENKAKUHANKAKU, KEY_102ND, KEY_F11, KEY_F12, KEY_RO, KEY_KATAKANA, KEY_HIRAGANA, KEY_HENKAN, KEY_KATAKANAHIRAGANA, KEY_MUHENKAN, KEY_KPJPCOMMA, KEY_KPENTER, KEY_RIGHTCTRL, KEY_KPSLASH, KEY_SYSRQ, KEY_RIGHTALT, KEY_HOME, KEY_UP, KEY_PAGEUP, KEY_LEFT, KEY_RIGHT, KEY_END, KEY_DOWN, KEY_PAGEDOWN, KEY_INSERT, KEY_DELETE, KEY_MUTE, KEY_VOLUMEDOWN, KEY_VOLUMEUP, KEY_POWER, KEY_KPEQUAL, KEY_PAUSE, KEY_KPCOMMA, KEY_HANGEUL, KEY_HANJA, KEY_YEN, KEY_LEFTMETA, KEY_RIGHTMETA, KEY_COMPOSE, KEY_STOP, KEY_AGAIN, KEY_PROPS, KEY_UNDO, KEY_FRONT, KEY_COPY, KEY_OPEN, KEY_PASTE, KEY_FIND, KEY_CUT, KEY_HELP, KEY_KPLEFTPAREN, KEY_KPRIGHTPAREN, KEY_F13, KEY_F14, KEY_F15, KEY_F16, KEY_F17, KEY_F18, KEY_F19, KEY_F20, KEY_F21, KEY_F22, KEY_F23, KEY_F24, KEY_UNKNOWN]
          EV_MSC: [MSC_SCAN]
          EV_LED: [LED_NUML, LED_CAPSL, LED_SCROLLL, LED_COMPOSE, LED_KANA]
          EV_REP:
            REP_DELAY: 200
            REP_PERIOD: 50
      '';
    in ''
      - CMD: "${mux} -c virtualKB"
      - JOB: "${mux} -i virtualKB | ${caps2esc} | ${uinput} -c ${virtualKeyboardYAML}"
      - JOB: "${intercept} -g $DEVNODE | ${mux} -o virtualKB"
        DEVICE:
          EVENTS:
            EV_KEY: [[KEY_CAPSLOCK, KEY_ESC]]
          LINK: .*-event-kbd
      - JOB: "${intercept} $DEVNODE | ${mux} -o virtualKB"
        DEVICE:
          EVENTS:
            EV_KEY: [BTN_LEFT, BTN_RIGHT, BTN_TOUCH]
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
    interception-tools
    libinput
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
