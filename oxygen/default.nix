(p: (import <nixpkgs> {}).callPackage p {})
(
{ runCommand, requireFile, jdk
  , buildFHSUserEnv, makeWrapper
}:
let
  env = buildFHSUserEnv {
    name = "oxygen-env";
    targetPkgs = pkgs: [ pkgs.jdk ];
    runScript = ''
      bash -c "set -x
      cp ${./oxygen.sh} ./install.sh
      chmod +x ./install.sh
      sh ./install.sh"
    '';

  };
in runCommand "oxygen-cmd" {
  installer = ./oxygen.sh;
  buildInputs = [ jdk makeWrapper ];
} ''
  (
    echo 2 # language: Engish
    echo o # confirm we want to install
    echo "" # go to the next page of the license
    echo "" # go to the next page of the license
    echo "" # go to the next page of the license
    echo "" # go to the next page of the license
    echo "" # go to the next page of the license
    echo "" # go to the next page of the license
    echo "" # go to the next page of the license
    echo "" # go to the next page of the license
    echo "" # go to the next page of the license
    echo "" # go to the next page of the license
    echo "" # go to the next page of the license
    echo "" # go to the next page of the license
    echo "" # go to the next page of the license
    echo "" # go to the next page of the license
    echo "" # go to the next page of the license
    echo "" # go to the next page of the license
    echo "" # go to the next page of the license
    echo 1 # accept the license
    echo /build/staged # install to this directory

    echo "" # accept the default list of components
            # (only one, and it was selected, at this time)

    echo "n" # make desktop symlinks
    echo "n" # Run Oxygen XML Editor now?

    echo "n" # Privacy Options, saying Yes failed b/c no X11
  ) | ${env}/bin/oxygen-env

  mv staged $out

  cd $out

  # Leaving the jre directory makes oxygen prefer its own JRE over
  # our provided java
  rm -rf jre
  wrapProgram $out/oxygen.sh \
    --set JAVA_HOME "$JAVA_HOME"



''
)
