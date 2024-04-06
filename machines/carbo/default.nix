{pkgs, ...}: {
  imports = [
    ../common.nix
    ../laptop.nix
    ./disko.nix
    ./hardware.nix
  ];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 8;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Disko takes care of this stuff!
  # boot.initrd.luks.devices.crypted.device = "/dev/disk/by-uuid/43aaf35b-817d-4d6d-b3d9-851f14db164c";
  # fileSystems."/".device = "/dev/mapper/crypted";

  environment.systemPackages = with pkgs; [
    dropbox
    nextcloud-client
    signal-desktop
  ];

  networking.hostName = "carbo";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  system.stateVersion = "23.11"; # Did you read the comment?
}
