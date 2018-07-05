{ pkgs, ... }:
let
  sourceTree = ./.;
  gitTree = builtins.fetchGit sourceTree;

  verifyCleanTree = srcTree: pkgs.runCommand "clean-tree"
    { buildInputs = [ pkgs.git ]; }
    ''
      cd ${srcTree}
      if ! git diff -q; then
        echo "FAIL FAIL FAIL";
        echo "MUST COMMIT YOUR CHANGES! DIRTY TREE DETECTED!"
      fi

      touch $out
    '';
in
{
  imports = [ "${gitTree}/main-configuration.nix" ];
  system.activationScripts.maybeBreak =
    pkgs.lib.addContextFrom (verifyCleanTree sourceTree) "";
}
