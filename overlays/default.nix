{
  inputs,
  system,
  ...
}: [
  (final: prev: let
    version = "0.9.0-pre";
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
              # sha256 = final.lib.fakeHash;
              sha256 = "sha256-cM4PiNbfE2sEQHzklBgsJdN/iVK0nT9iZ1F/Cb5tLtM=";
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
]
