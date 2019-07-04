#!/bin/sh

name=oxygen-$(date).sh
curl -L --output "$name" \
     https://mirror.oxygenxml.com/InstData/Editor/Linux64/VM/oxygen-64bit.sh

cp "$name" oxygen.sh
nix-hash --type sha256 --base32 "oxygen.sh" > oxygen.sh.hash
nix-store --add-fixed sha256 oxygen.sh
