{ stdenv, shellcheck }:
stdenv.mkDerivation {
  name = "is-nix-channel-up-to-date.sh";
  buildInputs = [ shellcheck ];

  src = ./is-nix-channel-up-to-date.sh;

  unpackPhase = ''
    cp $src ./
  '';

  buildPhase = ''
    shellcheck ./*.sh
  '';

  installPhase = ''
    ls
    cp ./*.sh $out
  '';
}
