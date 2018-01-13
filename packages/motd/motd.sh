#!/bin/sh

export TERM=xterm
#Background Colors
E=$(tput sgr0);    R=$(tput setab 1); G=$(tput setab 2); Y=$(tput setab 3);
B=$(tput setab 4); M=$(tput setab 5); C=$(tput setab 6); W=$(tput setab 7);

# normal
width="  ";
height=1;
clear=0

# for super high res / low font size screens:
width="            ";
height=5;
clear=1

function e() { echo -e "$E"; }
function x() { echo -n "$E$width"; }
function r() { echo -n "$R$width"; }
function g() { echo -n "$G$width"; }
function y() { echo -n "$Y$width"; }
function b() { echo -n "$B$width"; }
function m() { echo -n "$M$width"; }
function c() { echo -n "$C$width"; }
function w() { echo -n "$W$width"; }

#putpixels
function u() {
    h="$*";o=${h:0:1};v=${h:1};
    for i in `seq $v`
    do
        $o;
    done
}

img="\
r40 e1 y39 r1 e1 g38 y1 r1 e1 b37 g1 y1 r1 e1 c36 b1 g1 y1 r1 e1 m35 c1 b1 g1 y1 r1 e1 r6 w28 m1 c1 b1 g1 y1 r1 e1 r1 y6 w7 x3 w4 x4 w4 x2 w3 m1 c1 b1 g1 y1 r1 e1 r1 y1 g6 w6 x1 w1 x2 w3 x1 w2 x1 w3 x2 w1 x1 w2 m1 c1 b1 g1 y1 r1 e1 r1 y1 g1 b6 w4 x2 w6 x1 w5 x2 w3 x1 w1 m1 c1 b1 g1 y1 r1 e1 r1 y1 g1 b1 c6 w3 x1 w7 x2 w4 x1 w6 m1 c1 b1 g1 y1 r1 e1 r1 y1 g1 b1 c1 m6 w2 x1 w8 x2 w3 x1 w6 m1 c1 b1 g1 y1 r1 e1 r1 y1 g1 b1 c1 m1 w7 x1 w2 x3 w4 x2 w2 x1 w6 m1 c1 b1 g1 y1 r1 e1 r1 y1 g1 b1 c1 m1 w7 x1 w4 x1 w5 x1 w2 x1 w4 x1 w1 m1 c1 b1 g1 y1 r1 e1 r1 y1 g1 b1 c1 m1 w7 x3 w2 x1 w2 x1 w3 x1 w1 x3 w2 x1 w1 m1 c1 b1 g1 y1 r1 e1 r1 y1 g1 b1 c1 m1 w9 x4 w3 x3 w4 x3 w2 m1 c1 b1 g1 y1 r1 e1 r1 y1 g1 b1 c1 m1 w28 m1 c1 b1 g1 y1 r1 e1 r1 y1 g1 b1 c1 m30 c1 b1 g1 y1 r1 e1 r1 y1 g1 b1 c32 b1 g1 y1 r1 e1 r1 y1 g1 b34 g1 y1 r1 e1 r1 y1 g36 y1 r1 e1 r1 y38 r1 e1 r40"

for i in `seq 0 $clear`; do
    for i in `seq 1 $height`; do
        e
    done
done


line=""
for n in $img
do
    if [ "$n" = "e1" ]; then
        for i in `seq 1 $height`; do
            echo -n "$line"
            e
        done
        line=""
    else
      line="${line}$(u "$n")";
    fi
done
for i in `seq 1 $height`; do
    echo -n "$line"
    e
done

exit 0;
