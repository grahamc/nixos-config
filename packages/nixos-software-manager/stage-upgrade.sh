#!/bin/sh

set -eux

NIXPKGS="$1"

cache="${2:-${XDG_CACHE_HOME:-$HOME/.cache}}"
update_manager_dir="$cache/nixos-update-manager"
channel_link=$update_manager_dir/channel
channel_failed=$update_manager_dir/channel.failed
new_system=$update_manager_dir/system

mkdir -p "$update_manager_dir"
nix-build -I "nixpkgs=$NIXPKGS" --expr '
let pkgs = import <nixpkgs> {}; in pkgs.runCommand "channel" {} "
  ln -s ${pkgs.path} $out
"' --out-link "$channel_link"


set -eux

if [ -e "$channel_failed" ]; then
	currentpath=$(realpath "$channel_link")
	failedpath=$(realpath "$channel_failed")

	if [ "$currentpath" = "$failedpath" ]; then
		echo "Current channel fails."
		exit 1
	fi
fi

if ! nix-build \
	-I nixpkgs="$channel_link" \
       	'<nixpkgs/nixos>' \
	-A system \
	--keep-going \
	--out-link "$new_system"; then
	echo "Marking the channel as broken"
	ln -nfs "$channel_link" "$channel_failed"
	exit 1

fi

# switch the profile:
# nix-env --profile /nix/var/nix/profiles/system --set "$new_system"
# switch now:
# /nix/var/nix/profiles/system/bin/switch-to-configuration switch
# switch at next boot:
# /nix/var/nix/profiles/system/bin/switch-to-configuration boot 
