{ resholve, mutate, vim, oil, gzip, coreutils, pstree, jq, utillinux }:
target:
resholve {
  src = mutate ./snoop.sh {
    inherit target oil;
  };

  inputs = [ gzip coreutils jq vim pstree utillinux ];
}
