{ mutate, pulseaudioFull, coreutils, gnugrep }:
mutate ./volume.sh {
  inherit pulseaudioFull coreutils gnugrep;
}
