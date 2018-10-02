{ stdenv, mutate, shellcheck, findutils, coreutils, gnused, git }:
stdenv.mkDerivation rec {
  name = "did-graham-commit-his-repos";
  buildInputs = [ shellcheck ];

  src = mutate ./summary.sh { inherit checker findutils coreutils gnused; };
  checker = mutate ./check.sh { inherit coreutils git; };

  unpackPhase = ''
    cp $src ./
  '';

  buildPhase = ''
    shellcheck $src $checker
  '';

  installPhase = ''
    cp $src $out
  '';
}
