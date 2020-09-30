{ resholve, coreutils, gnugrep, utillinux, jq, systemd, sway }:
# Kill the cgroup of the focused window
resholve {
  src = ./wl-freeze.sh;
  inputs = [ coreutils jq gnugrep utillinux systemd sway ];
}

