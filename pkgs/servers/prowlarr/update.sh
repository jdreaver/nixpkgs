#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused nix-prefetch jq

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 VERSION" >&2
    echo "Example: $0 0.1.1.875" >&2
    exit 1
fi

version=$1

dirname="$(dirname "$0")"

updateHash()
{
    version=$1
    arch=$2
    os=$3

    hashKey="${arch}-${os}_hash"

    url="https://github.com/Prowlarr/Prowlarr/releases/download/v$version/Prowlarr.develop.$version.$os-core-$arch.tar.gz"
    hash=$(nix-prefetch-url --type sha256 $url)
    sriHash="$(nix hash to-sri --type sha256 $hash)"

    sed -i "s|$hashKey = \"[a-zA-Z0-9\/+-=]*\";|$hashKey = \"$sriHash\";|g" "$dirname/default.nix"
}

updateVersion()
{
    sed -i "s/version = \"[0-9.]*\";/version = \"$1\";/g" "$dirname/default.nix"
}

# N.B. Prowlarr is still in development, so
# https://api.github.com/repos/Prowlarr/Prowlarr/releases/latest
# returns nothing. Instead, we require the release as an argument. Go
# to https://github.com/Prowlarr/Prowlarr/releases to see releases.

# currentVersion=$(cd $dirname && nix eval --raw -f ../../.. prowlarr.version)

# latestTag=$(curl https://api.github.com/repos/Prowlarr/Prowlarr/releases/latest | jq -r ".tag_name")
# latestVersion="$(expr $latestTag : 'v\(.*\)')"

# if [[ "$currentVersion" == "$latestVersion" ]]; then
#     echo "Prowlarr is up-to-date: ${currentVersion}"
#     exit 0
# fi

updateVersion $version

updateHash $version x64 linux
updateHash $version arm64 linux
updateHash $version x64 osx
