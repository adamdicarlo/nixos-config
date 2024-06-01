{...}: {
  services.adguardhome = let
    host = "0.0.0.0";
    port = 5300;
  in {
    enable = true;
    openFirewall = true;
    inherit host port;
    settings = {
      http = {
        address = "${host}:${builtins.toString port}";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [53];
  networking.firewall.allowedUDPPorts = [53];
}
