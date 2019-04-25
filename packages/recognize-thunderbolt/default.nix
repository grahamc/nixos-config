{ mutate, coreutils, bash, openssl
, runCommand, findutils, diffutils}:
let src = mutate ./recognize-thunderbolt {
  inherit coreutils bash openssl findutils diffutils;
}; in runCommand "recognize-thunderbolt" {} ''
  mkdir -p $out/bin
  cp ${src} $out/bin/recognize-thunderbolt
''
