#!/bin/sh

set -eux

pid=$(swaymsg -t get_tree | jq '.. | select(.type?) | select(.focused==true).pid')
cgroup=$(cat "/proc/${pid}/cgroup" | cut -d: -f3- | rev | cut -d/ -f1 | rev)

state=$(systemctl --user show "$cgroup" | \
	awk -v FS== '$1 == "FreezerState" { print $2; }')

if [ "x$state" = "xfrozen" ]; then
	echo "Thawing $cgroup"
	systemctl --user thaw "$cgroup"
elif [ "x$state" = "xrunning" ]; then
	echo "Freezing $cgroup"
	systemctl --user freeze "$cgroup"
else
	echo "Unknown state: $state"
	exit 1
fi


