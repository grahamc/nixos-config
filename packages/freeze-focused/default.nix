{ resholve, coreutils, utillinux, jq, systemd, sway, gawk }:
# Freeze the cgroup of the focused window
resholve {
  src = ./freeze.sh;
  inputs = [ coreutils utillinux jq systemd sway gawk ];
}

