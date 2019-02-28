{ stdenv, fetchFromGitHub, python2, makeWrapper, buildEnv, xdotool,
  xsel, xprop, libnotify }:
let
  python = python2.withPackages (p: [
    p.jsonrpclib
  ]);

  binpath = buildEnv {
    name = "aenea-bin-path";
    paths = [
      xprop
      xdotool
      xsel
      libnotify
    ];
  };

in stdenv.mkDerivation {
  name = "aenea-2018-12-15";

  src = fetchFromGitHub {
    owner = "dictation-toolbox";
    repo = "aenea";
    rev = "78ce8aff2507bd0d6a2960ba40b5329034b96a5d";
    sha256 = "031zwn2ra15c3s0b3bic4fk3rq85cqlhh1f78xidnk4hvziarcn1";
  };

  buildInputs = [
    makeWrapper
    python
  ];

  configurePhase = ''

  '';

  buildPhase = ''
    (
      cd ./server/linux_x11
      patchShebangs ./
    )
  '';

  installPhase = ''
    mkdir $out
    mv ./* $out/
    wrapProgram $out/server/linux_x11/server_x11.py \
      --prefix PATH : "${binpath}/bin" \
      --set LANG en_US.UTF-8
    cp $out/server/linux_x11/config.py.example  $out/server/linux_x11/config.py

    ln -s $out/server/linux_x11/server_x11.py $out/server.py
  '';
}
