{ stdenv, fetchFromGitHub, python3, pass }:
stdenv.mkDerivation {
  name = "passff-host-1.0.3linux";

  src = fetchFromGitHub {
    owner = "passff";
    repo = "passff";
    rev = "1.0.3linux";
    sha256 = "0p1yhqy6aj2qvcd1278irm7bapjpd0ij57w3xz5fq7z2560x0p2j";
  };

  buildInputs = [ python3 ];

  buildPhase = ''
    patchShebangs .
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./src/host/passff.py $out/bin/passff.py

    mkdir -p $out/share/passff-host
    cp ./src/host/passff.json $out/share/passff-host/passff.json

    substituteInPlace $out/bin/passff.py \
      --replace "[receivedMessage['command']]" "['${pass}/bin/pass']"


    substituteInPlace $out/share/passff-host/passff.json \
      --replace PLACEHOLDER $out/bin/passff.py
  '';
}
