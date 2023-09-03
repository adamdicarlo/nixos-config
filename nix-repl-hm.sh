#/bin/bash
set -e
CODE="$(
	cat <<EOF
let
  hm = import <home-manager/modules> { configuration = ~/nixos-config/home.nix; pkgs = import <nixpkgs> {}; };
in
{ inherit hm; }
EOF
)"
tmp=$(mktemp)
printf '%s\n' "$CODE" >"$tmp"

echo "$CODE"
NIX_PATH=nixpkgs=http://nixos.org/channels/nixos-unstable/nixexprs.tar.xz:home-manager=https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz \
	nix repl --file "$tmp"
