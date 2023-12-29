{config, ...}: {
  imports = [
    ../common.nix
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
    defaults.email = "contact@sleeping-panda.net";
    preliminarySelfsigned = false;
  };

  services.adguardhome = {
    enable = true;
    # open ports for web interface
    openFirewall = true;
    settings = rec {
      http = {
        address = "${bind_host}:${builtins.toString bind_port}";
      };
      bind_host = "0.0.0.0";
      bind_port = 5300;
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [53 80 443];
  networking.firewall.allowedUDPPorts = [53];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "23.11"; # Did you read the comment?
}
