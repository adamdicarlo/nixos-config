{...}: {
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

  networking.firewall.allowedTCPPorts = [53];
  networking.firewall.allowedUDPPorts = [53];
}
