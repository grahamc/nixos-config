{ mutate, dmenu }:
mutate ./dunstrc {
  inherit dmenu;
  i3status_conf = ./dunstrc;
}
