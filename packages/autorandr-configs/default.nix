{ mutate, runCommand, lib, i3, xorg, jq, coreutils }:
let
  generated = ./generated-configs;

  prime-resolutions = mutate ./scripts/prime-resolutions.sh {
    inherit (xorg) xrandr;
  };
  move-frames = mutate ./scripts/move-frames.sh {
    binpath = lib.makeBinPath [
      i3 jq coreutils
    ];
  };
in runCommand "autorandr-merged-configs" {
    preswitch_scripts = [
      prime-resolutions
    ];
    postswitch_scripts = [
      move-frames
    ];
  }
  ''
  mkdir $out
  cp -r ${generated}/* $out

  mkdir $out/preswitch.d
  for script in $preswitch_scripts; do
    cp -r $script $out/preswitch.d
  done
  chmod +x $out/preswitch.d/* || true

  mkdir $out/postswitch.d
  for script in $postswitch_scripts; do
    cp -r $script $out/postswitch.d
  done
  chmod +x $out/postswitch.d/* || true
''
