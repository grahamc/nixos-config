{ resholve, coreutils, gnugrep, utillinux, jq, systemd, sway, gnused }:
# Kill the cgroup of the focused window
resholve {
  name = "wl-freeze";
  src = ./wl-freeze.sh;
  inputs = [ coreutils jq gnugrep utillinux systemd sway gnused ];
}

