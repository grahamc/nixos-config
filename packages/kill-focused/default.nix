{ resholve, coreutils, utillinux, jq, systemd, sway }:
# Kill the cgroup of the focused window
resholve {
  src = ./kill.sh;
  inputs = [ coreutils utillinux jq systemd sway ];
}

