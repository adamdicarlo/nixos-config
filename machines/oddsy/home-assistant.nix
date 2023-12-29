{
  config,
  pkgs,
  ...
}: {
  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    virt-manager
    usbutils
  ];
  users.users.adam = {
    extraGroups = ["libvirtd"];
  };
}
