# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{pkgs, ...}: {
  imports = [
    ../common.nix
    ../modules/adguardhome.nix
    ./hardware.nix
    ./disk-config.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = ["intel_iommu=on"];

  networking.hostName = "oddsy";
  networking.networkmanager.enable = false;
  networking.defaultGateway = "10.0.0.1";
  networking.bridges.br0.interfaces = ["enp3s0"];
  networking.interfaces.br0 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "10.0.0.2";
        prefixLength = 24;
      }
    ];
  };
  networking.nameservers = ["10.0.0.5"];
  networking.useDHCP = false;

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        ovmf.enable = true;
      };
      onShutdown = "shutdown";
    };
  };

  environment.systemPackages = with pkgs; [
    virt-manager
    usbutils
    OVMF
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbs7eDyOmFy3rZV4zCI6Pz+5srASislwVs36/XcM4sq"
  ];
  users.users.adam.extraGroups = ["libvirtd"];

  # Open ports in the firewall.
  networking.firewall = let
    haosSpicePort = 5900;
    hassWebPort = 8123;
  in {
    allowedTCPPorts = [haosSpicePort hassWebPort];
    # allowedUDPPorts = [];
  };

  # For more information, see `man configuration.nix` or
  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "24.05";
}
