_: {
  services.adguardhome = let
    httpHost = "127.0.0.1";
    httpPort = 5300;
  in {
    enable = true;
    openFirewall = true;
    host = httpHost;
    port = httpPort;
    settings = {
      dns = {
        bind_hosts = ["0.0.0.0" "::1"];
      };
      http = {
        address = "${httpHost}:${builtins.toString httpPort}";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [53];
  networking.firewall.allowedUDPPorts = [53];
}
