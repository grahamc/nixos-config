#!/bin/bash

set -eux

CHAN=18.03
DELAY=675
SENTINAL=/var/lib/is-nix-channel-up-to-date/up-to-date

fetch_channel_version() {
    curl "https://channels.nix.gsc.io/nixos-$CHAN/latest" \
        | cut -d' ' -f1
}

remove_sentinal() {
    echo "Removing sentinal from $SENTINAL"
    rm -f "$SENTINAL"
    exit 0
}

VERSION_CHAN=$(fetch_channel_version)
echo "Channel starts at $VERSION_CHAN"
echo "System is at $VERSION_LOCAL"

if [ "$VERSION_CHAN" == "$VERSION_LOCAL" ]; then
    touch "$SENTINAL"
else
    remove_sentinal
fi

while true; do
    sleep "$DELAY"

    VERSION_CHAN=$(fetch_channel_version)
    if [ "$VERSION_CHAN" != "$VERSION_LOCAL" ]; then
        printf "Channel changed to %s\\n" "$VERSION_CHAN"
        remove_sentinal
    fi
done
