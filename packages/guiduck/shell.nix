let
  pkgs = import ./nix {};
in
pkgs.mkShell {
  buildInputs = [
    pkgs.overlayed.niv.niv
    pkgs.overlayed.crate2nix
    pkgs.entr
    pkgs.cargo
    pkgs.rustfmt
    pkgs.clippy
    pkgs.hello
  ];
}
