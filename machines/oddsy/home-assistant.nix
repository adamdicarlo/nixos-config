{
  config,
  pkgs,
  ...
}: {
  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
  };

  # OVMF missing?
  # https://github.com/NixOS/nixpkgs/issues/378894#issuecomment-3694133635

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    virt-manager
    usbutils
  ];
  users.users.adam = {
    extraGroups = ["libvirtd"];
  };
}
