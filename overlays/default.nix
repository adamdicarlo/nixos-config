{
  inputs,
  system,
  ...
}: [
  (final: prev: let
    version = "0.9.1";
  in {
    # Based on https://github.com/rbelem/nix-config/blob/main/overlays/default.nix
    devbox = prev.devbox.override {
      buildGoModule = args:
        prev.buildGoModule.override {go = prev.go_1_21;} (args
          // {
            inherit version;
            src = final.fetchFromGitHub {
              owner = "jetpack-io";
              repo = "devbox";
              rev = version;
              # To update the sha256
              # hash = final.lib.fakeHash;
              hash = "sha256-3KZWXVwvzy3mZkh6pGZpeQQp2aU4V9TyBcJXU4Au4Rs=";
            };
            # To update the vendorHash
            # vendorHash = final.lib.fakeHash;
            vendorHash = "sha256-8G1JX4vdpDAicx6A9Butl8XTjszlHMbh34pJVQyzEs4=";

            ldflags = [
              "-s"
              "-w"
              "-X go.jetpack.io/devbox/internal/build.Version=${version}"
            ];
          });
    };
  })

  (final: prev: {
    openvpn = inputs.openaws-vpn-client.outputs.packages.${system}.openvpn;
    openaws-vpn-client = inputs.openaws-vpn-client.outputs.packages.${system}.openaws-vpn-client;
  })

  (final: prev: let
    version = "1128dbdaf85584a519f0ee7a4d06df892cd5e849";
  in {
    splix = prev.splix.overrideAttrs (old: {
      pname = "splix-gitlab";
      inherit version;
      src = prev.fetchzip {
        url = "https://gitlab.com/adamdicarlo/splix/-/archive/patches/splix-patches.tar.bz2?path=splix";
        hash = "sha256-Mi6cHbEOe1TyIdn8aoEV2EKEwXWRN9txbOOJlc2Z67c=";
        stripRoot = true;
      };
      postPatch = prev.lib.replaceStrings ["mv -v *.ppd ppd/"] ["cd splix"] old.postPatch;
    });
  })
]
