{ stdenv, git, coreutils, curl, nix }:
stdenv.mkDerivation {
  name = "nixpkgs-maintainer-tools";
  src = ./bin;

  stable = "release-18.03";
  oldstable = "release-17.09";
  tpath = "${curl}/bin:${git}/bin/:${coreutils}/bin:${nix}/bin";

  buildPhase = ''
    for f in $(ls); do
      substituteAllInPlace "$f"
    done
  '';

  installPhase = ''
    mkdir -p $out/
    cp -r . $out/bin
    chmod +x $out/bin/*
  '';
}
