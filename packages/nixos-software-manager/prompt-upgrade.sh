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
	--button-dismiss-no-terminal "What Changed?" "echo diff" \
	--button-dismiss-no-terminal "Next Boot" "echo later" \
	--button-dismiss-no-terminal "Now" "echo now" \
	--message "Upgrade from $prevversion to $newversion?")

withchoice() (
	/run/wrappers/bin/pkexec @switchto@ "$newsyspath" "$1" 2>&1 | zenity --text-info
)

promptdiff() (
	set +x
	(
		echo "Service Changes"
		"$newsyspath/bin/switch-to-configuration" dry-activate
		printf "\n\n\nDerivation Diff\n"
		prevdrv=$(nix-store --query --deriver "$prevsyspath")
		newdrv=$(nix-store --query --deriver "$newsyspath")
 		nix-diff "$prevdrv" "$newdrv"
	) 2>&1 | diffzenity
)

diffzenity() (
	set +e

	result=$(zenity --text-info \
		--ok-label "Next Boot" \
		--extra-button "Switch Now")
	code=$?
	if [ "$code" -eq 0 ] && [ "x$result" == "x" ]; then
		# "OK" button was pressed, ie: nextboot
		withchoice boot
	elif [ "$code" -eq 1 ] && [ "x$result" == "xSwitch Now" ]; then
		# "Switch Now" button selected
		withchoice switch
	elif [ "$code" -eq 1 ] && [ "x" == "x" ]; then
		# "Cancel" button selected
		:
	fi
)

case "$choice" in 
	now)
		withchoice switch
		;;
	later)
		withchoice boot
		;;
	diff)
		promptdiff
		;;
esac
