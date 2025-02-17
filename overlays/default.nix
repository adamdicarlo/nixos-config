{
  inputs,
  system,
  ...
}: [
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
