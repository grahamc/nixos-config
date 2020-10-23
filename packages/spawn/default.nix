{resholve, utillinux, coreutils, systemd }:
resholve {
  src = ./spawn.sh;
  inputs = [ utillinux coreutils systemd ];
}
