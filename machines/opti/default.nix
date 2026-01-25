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

  age.secrets.cloudflare_email.file = ../../secrets/cloudflare_email.age;
  age.secrets.cloudflare_api_key.file = ../../secrets/cloudflare_api_key.age;
  security.acme = {
    acceptTerms = true;
    certs."sleeping-panda.net" = {
      credentialFiles = {
        # https://go-acme.github.io/lego/dns/cloudflare/index.html#api-tokens
        #
        # With API tokens (CF_DNS_API_TOKEN, and optionally CF_ZONE_API_TOKEN),
        # very specific access can be granted to your resources at Cloudflare.
        #
        # The main resources Lego cares for are the DNS entries for your Zones. It also
        # needs to resolve a domain name to an internal Zone ID in order to manipulate
        # DNS entries.
        #
        # Hence, you should create an API token with the following permissions:
        #
        #    Zone / Zone / Read
        #    Zone / DNS / Edit
        #
        # You also need to scope the access to all your domains for this to work.
        # Then pass the API token as CF_DNS_API_TOKEN to Lego.
        CLOUDFLARE_EMAIL_FILE = config.age.secrets.cloudflare_email.path;
        CF_DNS_API_TOKEN_FILE = config.age.secrets.cloudflare_api_key.path;
      };
      domain = "sleeping-panda.net";
      dnsPropagationCheck = true;
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      extraDomainNames = ["*.sleeping-panda.net"];

      server = "https://acme-v02.api.letsencrypt.org/directory";

      # Let's Encrypt staging server:
      # server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    };
    defaults = {
      email = "contact@sleeping-panda.net";
      reloadServices = ["traefik"];
    };
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
    "d       ${services}/nextcloud   0750  33         root       -    -"
    "d       ${services}/sabnzbd     0775  sabnzbd    sabnzbd    -    -"
  ];

  system.stateVersion = "23.11"; # Did you read the comment?
}
