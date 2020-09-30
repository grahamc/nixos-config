{ resholve, mutate, light, bc, coreutils }:
resholve {
  name = "backlight";
  src = ./backlight.sh;
  inputs = [ bc light coreutils ];
}
