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

  naryKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDfGCziT8Dl41xDwDM3MkXPlaGbOXxfbUCiPPhISYH9j root@nary"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINsDwj67j3w/SMTLiS8b/d5Tn2LvSp09ks1PTBYlLNVe adam@nary"
  ];
in {
  "secrets/cloudflare_email.age".publicKeys = personalKeys;
  "secrets/cloudflare_api_key.age".publicKeys = personalKeys;
  "secrets/sabnzbd.ini.age".publicKeys = personalKeys;

  "secrets/s1_mgmt_token.age".publicKeys = naryKeys;
  "secrets/s1_customer_id.age".publicKeys = naryKeys;
}
