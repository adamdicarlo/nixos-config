{pkgs, ...}: {
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

  services.sabnzbd = {
    enable = true;
    configFile = "/mnt/slab/services/sabnzbd";
    openFirewall = true;
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
