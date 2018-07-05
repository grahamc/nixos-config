{ pkgs, ... }:
let
  sourceTree = ./.;
  gitTree = builtins.fetchGit sourceTree;

  verifyCleanTree = srcTree: pkgs.runCommand "clean-tree"
    { buildInputs = [ pkgs.git ]; }
    ''
      cd ${srcTree}
      if ! git diff --quiet --exit-code; then
        echo "FAIL FAIL FAIL";
        echo "MUST COMMIT YOUR CHANGES! DIRTY TREE DETECTED!"
        exit 1
      fi

      touch $out
    '';
in
{
  imports = [ "${gitTree}/main-configuration.nix" ];
  system.activationScripts.maybeBreak =
    pkgs.lib.addContextFrom (verifyCleanTree sourceTree) "";
}
