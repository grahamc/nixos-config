{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation rec {
  name = "monitor-hotplug-${version}";
  version = "0.0.1";
  src = ./src;

  buildInputs = with pkgs; [
    python3
    python35Packages.flake8
    makeWrapper
  ];
  installPhase = ''
  mkdir -p $out/bin
  cp -r main.py $out/bin/monitor-hotplug
  chmod +x $out/bin/monitor-hotplug

  wrapProgram "$out/bin/monitor-hotplug" \
    --prefix PATH : "${pkgs.xorg.xrandr}/bin"
  '';

  doCheck = true;
  checkPhase = ''
  find . -name '*.py' | xargs flake8
  DO_TEST=true python3 ./main.py
  '';
}
