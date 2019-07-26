# from githubusercontent.com/thefloweringash/kevin-nix/master/packages/ttf-console-font.nix
# Ported from http://urchlay.naptime.net/repos/ttf-console-fonts
# Upstream license is WTFPL (http://www.wtfpl.net/txt/copying)

{ stdenv, lib, runCommand, otf2bdf, bdf2psf }:

{ fontfile, dpi, ptSize }:

let
  bdf2psf-data = "${bdf2psf}/usr/share/bdf2psf";
in

runCommand "ttf-console-font" {
  buildInputs = [ otf2bdf bdf2psf ];
  sets = lib.concatStringsSep "+" (map (x: "${bdf2psf-data}/${x}") [
    "ascii.set"
    "linux.set"
    "fontsets/Lat2.256"
    "fontsets/Uni1.512"
    "useful.set"
  ]);
} ''
  otf2bdf ${fontfile} -r ${toString dpi} -p ${toString ptSize} -o tmp.bdf

  AV=$( sed -n 's,AVERAGE_WIDTH ,,p' tmp.bdf )
  AV=$(( ( AV + 30 ) / 10 * 10 ))
  sed -i "/AVERAGE_WIDTH/s, .*, $AV," tmp.bdf

  bdf2psf --fb tmp.bdf ${bdf2psf-data}/standard.equivalents $sets 512 $out
''
