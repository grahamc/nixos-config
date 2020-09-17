{ mutate, light, bc, coreutils }:
mutate ./backlight.sh {
  inherit bc light coreutils;
}
