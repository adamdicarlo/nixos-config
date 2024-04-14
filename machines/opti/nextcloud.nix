{pkgs, ...}: {
  virtualisation.docker.enable = true;

  environment.systemPackages = [pkgs.docker-compose];

  systemd.services.nextcloud-aio = let
    compose = pkgs.lib.getExe' pkgs.docker-compose "docker-compose";
  in {
    enable = true;
    description = "Nextcloud AIO (all-in-one) via docker-compose";
    partOf = ["docker.service"];
    after = ["docker.service"];
    restartTriggers = [./nextcloud.compose.yaml];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${compose} -f ${./nextcloud.compose.yaml} up -d --remove-orphans";
      ExecStop = "${compose} -f ${./nextcloud.compose.yaml} down";
      Restart = "on-failure";
      User = "nextcloud";
      Group = "nextcloud";
    };
    wantedBy = ["multi-user.target"];
  };
  systemd.tmpfiles.rules = [
    # type   path                    mode  user       group      age  argument
    "d       /srv/nextcloud          0750  nextcloud  nextcloud  -    -"
  ];

  users.users.nextcloud = {
    home = "/srv/nextcloud";
    group = "nextcloud";
    extraGroups = ["docker"];
    isSystemUser = true;
  };
  users.groups.nextcloud.members = ["nextcloud"];

  users.users.adam.extraGroups = ["docker" "nextcloud"];
}
