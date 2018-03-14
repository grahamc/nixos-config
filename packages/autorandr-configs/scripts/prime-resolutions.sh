#!/bin/sh

export PATH=@xrandr@/bin

xrandr --newmode "2560x1440_30.00"  146.25  2560 2680 2944 3328  1440 1443 1448 1468 -hsync +vsync
xrandr --addmode HDMI1 "2560x1440_30.00"
xrandr --addmode DP1-1 "2560x1440_30.00"
