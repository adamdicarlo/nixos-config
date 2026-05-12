{config, pkgs, ...}: let
  compose = pkgs.lib.getExe' pkgs.docker-compose "docker-compose";
  outputDir = "/mnt/slab/media/youtube";
in {
  virtualisation.docker.enable = true;
  environment.systemPackages = [pkgs.docker-compose];

  systemd.services.youtarr = {
    enable = true;
    description = "Youtarr";
    partOf = ["docker.service"];
    after = ["docker.service"];
    restartTriggers = [./youtarr.compose.yaml];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${compose} -f ${./youtarr.compose.yaml} up -d --remove-orphans";
      ExecStop = "${compose} -f ${./youtarr.compose.yaml} down";
      Restart = "on-failure";
      User = "youtarr";
      Group = "youtarr";
      WorkingDirectory = "/srv/youtarr";
    };
    environment = {
      YOUTARR_UID = toString config.users.users.youtarr.uid;
      YOUTARR_GID = toString config.users.groups.youtarr.gid;
      YOUTARR_HOST_PORT = "3087";
      YOUTUBE_OUTPUT_DIR = outputDir;
      TZ = "America/Los_Angeles";
    };
    wantedBy = ["multi-user.target"];
  };
  systemd.tmpfiles.rules = [
    # type   path                                  mode  user     group    age  argument
    "d       ${outputDir}                          0775  youtarr  youtarr  -    -"
    "Z       ${outputDir}                          0775  youtarr  youtarr  -    -"
    "d       /srv/youtarr                          0750  youtarr  youtarr  -    -"
    "d       /srv/youtarr/server                   0775  youtarr  youtarr  -    -"
    "d       /srv/youtarr/server/images            0775  youtarr  youtarr  -    -"
    "d       /srv/youtarr/config                   0775  youtarr  youtarr  -    -"
    "d       /srv/youtarr/jobs                     0775  youtarr  youtarr  -    -"
    "d       /srv/youtarr/database                 0775  root     root     -    -"
  ];

  users.users.youtarr = {
    home = "/srv/youtarr";
    group = "youtarr";
    extraGroups = ["docker"];
    isSystemUser = true;
  };
  users.groups.youtarr.members = ["youtarr"];

  users.users.adam.extraGroups = ["docker" "youtarr"];

  environment.shellAliases = {
    ytd = "${compose} -f ${./youtarr.compose.yaml}";
  };
}
