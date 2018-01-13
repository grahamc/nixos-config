{ mutate, terminator, xorg, i3status, dropbox, dmenu, pulseaudioFull,
  volume, backlight, dunst, dunst_config }:
mutate ./config {
  inherit terminator i3status dropbox dmenu pulseaudioFull volume backlight dunst dunst_config;
  i3status_conf = ./i3status;
}
