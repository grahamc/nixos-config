{ stdenv, fetchFromGitHub, python3, pass }:
stdenv.mkDerivation {
  name = "passff-host-1.3";

  src = fetchFromGitHub {
    owner = "passff";
    repo = "passff-host";
    rev = "1.0.1";
    sha256 = "1rka47v0apjrj2h0d9vqp7lzjkh75chjk0fpl3bpa67d2197vsah";
  };

  buildInputs = [ python3 ];

  patches = [
    ./paths.patch
  ];

  buildPhase = ''
    patchShebangs .
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./src/passff.py $out/bin/passff.py

    mkdir -p $out/share/passff-host
    cp ./src/passff.json $out/share/passff-host/passff.json

    substituteInPlace $out/bin/passff.py \
      --replace "@PATH@" ""
    substituteInPlace $out/bin/passff.py \
      --replace "@PASS@" "${pass}/bin/pass"
    substituteInPlace $out/bin/passff.py \
      --replace "@VERSION@" "1.0.1"


    substituteInPlace $out/share/passff-host/passff.json \
      --replace PLACEHOLDER $out/bin/passff.py
  '';
}
