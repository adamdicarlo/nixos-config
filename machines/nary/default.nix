# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  sentinelonePath =
    "/opt/sentinelone/bin:"
    + lib.makeBinPath [
      pkgs.coreutils
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      config.systemd.package
    ];
  sentinelonePkg = lib.hiPrio (pkgs.writeShellApplication {
    name = "sentinelctl";
    text = ''
      if [ "$EUID" -ne 0 ]; then
        echo "$0 must be run with root privileges" >&2
        exit 1
      fi
      export PATH=${lib.escapeShellArg sentinelonePath}
      exec /opt/sentinelone/bin/sentinelctl "$@"
    '';
  });

  inherit (pkgs.stdenv.hostPlatform) system;
in {
  imports = [
    ../common.nix
    ../laptop.nix
    ./hardware.nix
    inputs.nixos-hardware.nixosModules.system76
    inputs.sentinelone.nixosModules.sentinelone
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."luks-98e30c24-6e36-4d00-a444-2adc1d41580d".device = "/dev/disk/by-uuid/98e30c24-6e36-4d00-a444-2adc1d41580d";
  networking.hostName = "nary"; # Define your hostname.

  # throttled doesn't support i9-13900HX.
  # undervolting seems to be locked in firmware.
  services.undervolt = {
    enable = false;
    tempBat = 75;
    tempAc = 80;
    p2.limit = 90;
    p2.window = 1;
  };

  programs._1password = {
    enable = true;
  };
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["adam"];
  };

  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        google-chrome-stable
        vivaldi
        zen
      '';
      mode = "0755";
    };
  };

  security.polkit = {
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id === "com.1password.1Password.authorizeSshAgent"
          && subject.isInGroup("wheel")
          && action.message
          && action.message.includes("1Password is trying to allow “kitty” to use the key “GitHub” for SSH")
        ) {
          return polkit.Result.AUTH_SELF_KEEP
        }
      })
    '';
  };

  age.secrets.s1_mgmt_token.file = ../../secrets/s1_mgmt_token.age;
  age.secrets.s1_customer_id.file = ../../secrets/s1_customer_id.age;
  # Agent-generated transient services execute /opt/sentinelone/bin/sentinelctl
  # directly, bypassing the upstream FHS wrapper. Keep the signed binary intact:
  # patching its ELF loader makes the agent reject its control connection.
  programs.nix-ld.enable = true;

  # The report command invokes sentinelctl and shell utilities by name. The
  # signed binary can now run directly, without upstream's FHS wrapper.
  environment.systemPackages = [
    inputs.drata.packages.${system}.drata-agent

    sentinelonePkg
  ];

  # systemd also applies this prefix drop-in to sentinel-agent-task-<id>.service.
  systemd.units."sentinel-agent-task-.service" = {
    overrideStrategy = "asDropin";
    text = ''
      [Service]
      Environment="PATH=${sentinelonePath}"
    '';
  };

  system.autoUpgrade = {
    enable = true;
    # https://discourse.nixos.org/t/best-practices-for-auto-upgrades-of-flake-enabled-nixos-systems/31255/18
    flake = "path:${config.users.users.adam.home}/nixos-config#${config.networking.hostName}";
    dates = "Mon,Wed,Fri 15:00";
    persistent = true;
    randomizedDelaySec = "1min";
  };

  services.sentinelone = {
    enable = true;
    sentinelOneManagementTokenPath = config.age.secrets.s1_mgmt_token.path;
    package = pkgs.sentinelone.overrideAttrs (_old: {
      version = "26.1.3.2";
      src = ./SentinelAgent_linux_x86_64_v26_1_3_2.deb;
    });
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?
}
