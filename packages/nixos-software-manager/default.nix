{ resholve, mutate, coreutils, sway, nix, gnome3 }:
let 
  switchto = resholve {
    src = ./switch-to;
    inputs = [ nix ];
    allow = {
      resholved_inputs = [
        "/nix/var/nix/profiles/system/bin/switch-to-configuration"
      ];
    };
  };

  stage-upgrade = resholve {
    src = ./stage-upgrade.sh;
    inputs = [ coreutils nix ];
  };

  prompt-upgrade = resholve {
    src = mutate ./prompt-upgrade.sh {
      inherit switchto;
    };
    inputs = [ coreutils sway gnome3.zenity ];
    allow = {
      resholved_inputs = [
	"/run/wrappers/bin/pkexec"
        "/run/current-system/sw/bin/nixos-version"
      ];
    };
  };
in { inherit stage-upgrade prompt-upgrade; }
