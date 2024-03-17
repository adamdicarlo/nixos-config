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
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
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

  users.users.adam.extraGroups = ["sabnzbd"];
  users.users.sonarr.extraGroups = ["sabnzbd"];
  users.users.radarr.extraGroups = ["sabnzbd"];
}
