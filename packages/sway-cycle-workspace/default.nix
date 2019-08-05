{ mutate, lib, sway, jq, coreutils, gnugrep }:
mutate ./cycle-workspace.sh {
  pkg_path = lib.makeBinPath [
    sway
    jq
    coreutils
    gnugrep
  ];
}
