{ mutate, resholve, grahamc, bemenu, utillinux, systemd }:
resholve {
  src = mutate ./launch.sh { bins = "${grahamc.guis}/bin"; };
  inputs = [ bemenu utillinux systemd ];
}
