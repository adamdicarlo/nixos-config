{config, ...}: {
  users.users.traefik.extraGroups = ["acme"];

  services.traefik = let
    certDir = config.security.acme.certs."sleeping-panda.net".directory;

    routeMap = {
      adguardhome = "http://localhost:5300/";
      adguardhome2 = "http://10.0.0.3:5300/";
      hass = "http://10.0.0.3:8123/";
    };

    traefik = {
      rule = "Host(`traefik.sleeping-panda.net`)";
      entryPoints = "websecure";
      service = "api@internal";
      tls = true;
    };

    routers =
      (builtins.mapAttrs (
          service: url: {
            inherit service;
            entryPoints = "websecure";
            rule = "Host(`${service}.sleeping-panda.net`)";
            tls = true;
          }
        )
        routeMap)
      // {inherit traefik;};

    services =
      builtins.mapAttrs (service: url: {
        loadBalancer.servers = [{inherit url;}];
      })
      routeMap;
  in {
    enable = true;
    dynamicConfigOptions = {
      http = {
        inherit routers services;
      };
      tls = {
        certificates = [
          {
            certFile = "${certDir}/cert.pem";
            keyFile = "${certDir}/key.pem";
            stores = ["default"];
          }
        ];
      };
    };
    staticConfigOptions = {
      api.dashboard = true;
      dns = ["localhost"];
      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entryPoint = {
            to = "websecure";
            scheme = "https";
            permanent = true;
          };
        };
        websecure = {
          address = ":443";
        };
      };
      global = {
        checkNewVersion = false;
        sendAnonymousUsage = false;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
