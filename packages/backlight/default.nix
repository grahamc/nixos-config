{ mutate, xorg, bc }:
mutate ./backlight.sh {
  inherit bc;
  inherit (xorg) xbacklight;
}
