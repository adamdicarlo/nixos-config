{config, ...}: {
  imports = [
    ../common.nix
    ../modules/adguardhome.nix
    ./hardware.nix
    ./traefik.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "opti";

  # environment.systemPackages = with pkgs; [
  # ];

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

  # Open ports in the firewall.
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "23.11"; # Did you read the comment?
}
