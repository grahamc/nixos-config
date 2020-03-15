{ resholve, mutate, light, bc, coreutils }:
resholve {
  src = ./backlight.sh;
  inputs = [ bc light coreutils ];
}
