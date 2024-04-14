{config, ...}: {
  users.users.traefik.extraGroups = ["acme"];

  services.traefik = let
    certDir = config.security.acme.certs."sleeping-panda.net".directory;

    routerServerPairs = [
      (simple "adguardhome" "http://localhost:5300/")
      (simple "adguardhome2" "http://10.0.0.2:5300/")
      (simple "bazarr" "http://localhost:6767/")
      (simple "hass" "http://10.0.0.3:8123/")
      (simple "jellyfin" "http://localhost:8096/")
      (simple "jellyseerr" "http://localhost:5055/")
      (simple "openwrt" "http://10.0.0.1/")
      (simple "radarr" "http://localhost:7878/")
      (simple "sabnzbd" "http://localhost:8080/")
      (simple "sonarr" "http://localhost:8989/")
      {
        router = {
          rule = "Host(`nextcloud.sleeping-panda.net`)";
          entryPoints = "websecure";
          middlewares = ["nextcloud-chain"];
          service = "nextcloud";
          tls = true;
        };
        serverUrl = "http://localhost:8000/";
      }
      {
        router = {
          rule = "Host(`traefik.sleeping-panda.net`)";
          entryPoints = "websecure";
          service = "api@internal";
          tls = true;
        };
        serverUrl = null;
      }
    ];

    simple = service: url: {
      router = {
        inherit service;
        entryPoints = "websecure";
        rule = "Host(`${service}.sleeping-panda.net`)";
        tls = true;
      };
      serverUrl = url;
    };

    routers =
      builtins.map (service: service.router) routerServerPairs;

    services =
      builtins.listToAttrs
      (
        builtins.map (
          service: {
            name = service.router.service;
            value = {
              loadBalancer.servers = [{url = service.serverUrl;}];
            };
          }
        )
        (
          builtins.filter
          (service: service.serverUrl != null)
          routerServerPairs
        )
      );

    middlewares = {
      nextcloud-secure-headers = {
        headers = {
          hostsProxyHeaders = [
            "X-Forwarded-Host"
          ];
          referrerPolicy = "same-origin";
        };
      };
      https-redirect = {
        redirectscheme = {
          scheme = "https";
        };
      };
      nextcloud-chain = {
        chain = {
          middlewares = [
            "https-redirect"
            "nextcloud-secure-headers"
          ];
        };
      };
    };
  in {
    enable = true;
    dynamicConfigOptions = {
      http = {
        inherit middlewares routers services;
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
