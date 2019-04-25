
{ fetchFromGitHub, ruby, stdenv, ifd }:
let
  src = fetchFromGitHub {
    owner = "zimbatm";
    repo = "h";
    rev = "6ead1888af579531a4e9282207ba55724086d795";
    sha256 = "1hzv3hwiv86v5k936691g6lzd8drrqnjc7hy7bjgc2qcnvf6xi8z";
  };
in ifd src (import src { pkgs = { inherit ruby stdenv; }; })
