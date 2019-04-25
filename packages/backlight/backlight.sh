#!/bin/sh

set -eu

PATH="@light@/bin/:@bc@/bin/"

CURPCT=$(light)
echo "CUR: $CURPCT"

if [ "$1" = "up" ]; then
    CMP=">="
else
    CMP=">"
fi

echo "CMP: $CMP"

if [ $(echo "$CURPCT $CMP 30" | bc) -eq 1 ]; then
    incr=10;
elif [ $(echo "$CURPCT $CMP 5" | bc) -eq 1 ]; then
    incr=5
else
    incr=1
fi
echo "incr: $incr"

if [ $(echo "$CURPCT >= 100" | bc) -eq 1 ] && [ "$1" = "up" ]; then
    # Don't go up!
    incr=0
fi
echo "protected incr: $incr"

if [ "$1" = "up" ]; then
    echo "inc"
    light -A $incr;
else
    echo "dec"
    light -U $incr;
fi
