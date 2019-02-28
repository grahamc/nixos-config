{ mutate, runCommand, lib, i3, xorg, jq, coreutils }:
let
  generated = ./generated-configs;

  move-frames = mutate ./scripts/move-frames.sh {
    binpath = lib.makeBinPath [
      i3 jq coreutils
    ];
  };
in runCommand "autorandr-merged-configs" {
    postswitch_scripts = [
      move-frames
    ];
  }
  ''
  mkdir -p $out/autorandr
  cp -r ${generated}/* $out/autorandr

  mkdir $out/autorandr/postswitch.d
  for script in $postswitch_scripts; do
    cp -r $script $out/autorandr/postswitch.d
  done
  chmod +x $out/autorandr/postswitch.d/*
''
