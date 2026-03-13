{config, pkgs, ...}: {
  # https://nixos.wiki/wiki/Jellyfin
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
      intel-compute-runtime
    ];
  };

  services.jellyfin = {
    enable = true;
    dataDir = "/mnt/slab/services/jellyfin";
    openFirewall = true;
  };

  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  services.bazarr = {
    enable = true;
    openFirewall = true;
  };

  services.radarr = {
    enable = true;
    dataDir = "/mnt/slab/services/radarr";
    openFirewall = true;
  };

  age.secrets.sabnzbd.file = ../../secrets/sabnzbd.ini.age;
  age.secrets.sabnzbd.owner = config.services.sabnzbd.user;
  age.secrets.sabnzbd.group = config.services.sabnzbd.group;
  services.sabnzbd = {
    enable = true;
    configFile = null;
    openFirewall = true;
    secretFiles = [config.age.secrets.sabnzbd.path];
    settings = {
      misc = {
        cache_limit = "2G";
        host_whitelist = "sabnzbd.sleeping-panda.net";
        dirscan_dir = "/mnt/slab/downloads";
        download_dir = "/mnt/slab/downloads/incomplete";
        complete_dir = "/mnt/slab/downloads/complete";
        port = 8080;
      };
    };
  };

  services.sonarr = {
    enable = true;
    dataDir = "/mnt/slab/services/sonarr";
    openFirewall = true;
  };

  users.users.adam.extraGroups = ["jellyfin" "sabnzbd" "radarr" "sonarr"];
  users.users.bazarr.extraGroups = ["radarr" "sonarr"];
  users.users.radarr.extraGroups = ["sabnzbd"];
  users.users.sonarr.extraGroups = ["sabnzbd"];
  users.users.jellyfin.extraGroups = ["sabnzbd" "radarr" "sonarr" "bazarr"];
}
