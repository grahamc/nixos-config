#!/bin/sh

set -eux

pid=$(swaymsg -t get_tree | jq '.. | select(.type?) | select(.focused==true).pid')
cgroup=$(cat "/proc/${pid}/cgroup" | cut -d: -f3- | rev | cut -d/ -f1 | rev)

systemctl --user kill "$cgroup"

