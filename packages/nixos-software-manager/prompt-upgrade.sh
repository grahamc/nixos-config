#!/bin/sh

set -eux

NIXPKGS="$1"

cache="${2:-${XDG_CACHE_HOME:-$HOME/.cache}}"
update_manager_dir="$cache/nixos-update-manager"
channel_link=$update_manager_dir/channel
new_system=$update_manager_dir/system

mkdir -p "$update_manager_dir"

newsyspath=$(readlink -f "$new_system")
prevsyspath=$(readlink -f /nix/var/nix/profiles/system)

if [ ! -e "$newsyspath" ]; then
	echo "No new system."
	exit 0
fi

if [ "$newsyspath" = "$prevsyspath" ]; then
	echo "System remains unchanged."
	exit 0
fi

prevversion="$(/run/current-system/sw/bin/nixos-version)"
newversion="$($newsyspath/sw/bin/nixos-version)"

choice=$(swaynag \
	--button-dismiss-no-terminal "Next Boot" "echo later" \
	--button-dismiss-no-terminal "Now" "echo now" \
	--message "Upgrade from $prevversion to $newversion?")

(
case "$choice" in 
	now)
		/run/wrappers/bin/pkexec @switchto@ "$newsyspath" switch
		;;
	later)
		/run/wrappers/bin/pkexec @switchto@ "$newsyspath" boot
		;;
esac
) 2>&1 | zenity --text-info

