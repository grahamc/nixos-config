{ mutate, light, bc }:
mutate ./backlight.sh {
  inherit bc light;
}
