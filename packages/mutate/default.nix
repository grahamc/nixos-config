{ stdenvNoCC }:
script: args:
(stdenvNoCC.mkDerivation (args // {
  name = baseNameOf script;
  phases = [ "installPhase" ];

  installPhase = ''
    cp ${script} $out
    substituteAllInPlace $out
    patchShebangs $out
  '';
}))
