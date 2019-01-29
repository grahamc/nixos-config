{ fetchFromGitHub, ruby, stdenv }:
let
  src = fetchFromGitHub {
    owner = "zimbatm";
    repo = "h";
    rev = "62895d3d9abc35dd1b142f4053c4b1d6eab90259";
    sha256 = "0bkybrgd5hkr87d6hfwl92iwqk9jb3fqgagn12gy5qyvz5la7mvm";
  };
in import src { pkgs = { inherit ruby stdenv; }; }
