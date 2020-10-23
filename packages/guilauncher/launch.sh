#!/usr/bin/env bash

set -eux

bins=@bins@

program=$(PATH="$bins" bemenu-run -i --no-exec)
if [ -n "$program" ]; then
	uuid=$(uuidgen)
	systemd-run --user --scope --unit "run-${program}-${uuid}" \
		--setenv=BEMENU_BACKEND=wayland \
		--setenv=PATH=":" \
		"$bins/$program"
fi
