#!/bin/sh

set -eu

PATH="@pulseaudioFull@/bin/:@gnugrep@/bin/:@coreutils@/bin"

CURVOL=$(pactl list sinks | grep Volume | cut -d"/" -f4 | cut -d% -f1)

if [ "$1" = "up" ]; then
    CMP="-ge"
else
    CMP="-gt"
fi

if [ $CURVOL $CMP 30 ]; then
    incr=10;
elif [ $CURVOL $CMP 5 ]; then
    incr=5
else
    incr=1
fi

if [ $CURVOL -ge 100 ] && [ "$1" = "up" ]; then
    # Don't go up!
    incr=0
fi

if [ "$1" = "up" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ +$incr%
else
    pactl set-sink-volume @DEFAULT_SINK@ -$incr%
fi
