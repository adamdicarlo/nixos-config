let
  carbo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB3fAS34JeKTKLFR2gm9sR1NZxH6GrPPyJHAe1eUJGOf";
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdkMQXU0GnQrywSxdWR32tY85EvkNBDWT40SbyvU3qX";

  laptops = [
    carbo # personal machine
    nixos # work-machine-to-be
  ];
  adam = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbs7eDyOmFy3rZV4zCI6Pz+5srASislwVs36/XcM4sq"
  ];
  adamWork = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHuKcZZc8H73Brm6B7wIcGuInLH5t48ezXRDw4rurAi"
  ];
  users = adam ++ adamWork;
in
{
}
