{ resholve, coreutils, utillinux, jq, systemd, sway }:
# Kill the cgroup of the focused window
resholve {
  name = "kill-focused";
  src = ./kill.sh;
  inputs = [ coreutils utillinux jq systemd sway ];
}

