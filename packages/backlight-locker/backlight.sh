#!/bin/sh

set -eux

PATH="@light@/bin/:@bc@/bin/"

CURPCT=$(light)
echo "CUR: $CURPCT"



if [ "$1" = "up" ]; then
    TO=$(echo "$CURPCT / 0.3" | bc)
    light -S $TO;
else
    TO=$(echo "$CURPCT * 0.3" | bc)
    light -S $TO;
fi

printf "now: %s\n" "$(light)"
