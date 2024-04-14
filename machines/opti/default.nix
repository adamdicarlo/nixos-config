{config, ...}: {
  imports = [
    ../common.nix
    ../modules/adguardhome.nix
    ./hardware.nix
    ./jellyfin.nix
    ./nextcloud.nix
    ./traefik.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "opti";

  age.secrets.namecheap_api_key.file = ../../secrets/namecheap_api_key.age;
  age.secrets.namecheap_api_user.file = ../../secrets/namecheap_api_user.age;
  security.acme = {
    acceptTerms = true;
    certs."sleeping-panda.net" = {
      # FAILED? Public IP probably changed!
      # https://ap.www.namecheap.com/settings/tools/apiaccess/whitelisted-ips
      credentialFiles = {
        NAMECHEAP_API_USER_FILE = config.age.secrets.namecheap_api_user.path;
        NAMECHEAP_API_KEY_FILE = config.age.secrets.namecheap_api_key.path;
      };
      domain = "sleeping-panda.net";
      dnsProvider = "namecheap";
      dnsPropagationCheck = true;
      extraDomainNames = ["*.sleeping-panda.net"];
      server = "https://acme-v02.api.letsencrypt.org/directory";

      # Let's Encrypt staging server:
      # server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    };
    defaults = {
      email = "contact@sleeping-panda.net";
      renewInterval = "monthly";
    };
    preliminarySelfsigned = false;
  };

  systemd.tmpfiles.rules = let
    services = "/mnt/slab/services";
  in [
    # type   path                    mode  user       group      age  argument
    "d       /mnt                    0775  root       root       -    -"
    "d       /mnt/slab               0775  root       root       -    -"
    "Z       /mnt/slab/downloads     0775  sabnzbd    sabnzbd    -    -"
    "d       /mnt/slab/media/tv      0775  sonarr     sonarr     -    -"
    "d       /mnt/slab/media/movies  0775  radarr     radarr     -    -"
    "d       ${services}             0775  root       root       -    -"
    "d       ${services}/sabnzbd     0775  sabnzbd    sabnzbd    -    -"
  ];

  system.stateVersion = "23.11"; # Did you read the comment?
}
