let
  carbo = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB3fAS34JeKTKLFR2gm9sR1NZxH6GrPPyJHAe1eUJGOf"];
  opti = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdkMQXU0GnQrywSxdWR32tY85EvkNBDWT40SbyvU3qX"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfEJnE9WhKq0zE+italQUTe1aD8i78agvJqxvKiYwQL"
  ];

  personalMachines = carbo ++ opti;
  personalUsers = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbs7eDyOmFy3rZV4zCI6Pz+5srASislwVs36/XcM4sq" # adam@carbo
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAmnxtjriZ/yJPYaVjT4INvuf5n6/SAzoRgqnQoopEj" # adam@opti
  ];
  personalKeys = personalUsers ++ personalMachines;
  # tiv = ["..."];
  # workMachines = tiv;
  # workUsers = [
  #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHuKcZZc8H73Brm6B7wIcGuInLH5t48ezXRDw4rurAi"
  # ];
  # workKeys = workUsers ++ workMachines;
in {
  "secrets/namecheap_api_user.age".publicKeys = personalKeys;
  "secrets/namecheap_api_key.age".publicKeys = personalKeys;
}
