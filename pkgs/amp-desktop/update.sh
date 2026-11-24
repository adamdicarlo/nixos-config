#!/usr/bin/env bash
# Write the latest amp-desktop version in the upstream Debian repository, and
# its hash, to version.json, which package.nix reads. The hash comes from the
# repository index, so the .deb itself isn't downloaded.
set -euo pipefail

index_url=https://static.ampcode.com/linux/dists/stable/main/binary-amd64/Packages
version_json="$(dirname "$0")/version.json"

index=$(curl -fsSL "$index_url")
version=$(awk '/^Package: amp-desktop$/ { p = 1 } p && /^Version:/ { print $2; exit }' <<<"$index")
sha256=$(awk '/^Package: amp-desktop$/ { p = 1 } p && /^SHA256:/ { print $2; exit }' <<<"$index")

if [[ -z "$version" ]] || [[ -z "$sha256" ]]; then
	echo "Couldn't find amp-desktop version/hash in $index_url" >&2
	exit 1
fi

hash=$(nix hash convert --hash-algo sha256 --to sri "$sha256")

printf '{\n  "version": "%s",\n  "hash": "%s"\n}\n' "$version" "$hash" >"$version_json"

echo "amp-desktop: $version"
