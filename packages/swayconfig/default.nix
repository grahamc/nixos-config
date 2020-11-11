{ mutate, xorg, bemenu, waybar, pulseaudioFull,
  volume, backlight, mako, lib, screenshot, sway-cycle-workspace,
  systemd, secrets, grahamc, kill-focused, freeze-focused, pavucontrol }:
  mutate ./config {
  inherit bemenu pulseaudioFull volume
  backlight mako screenshot systemd;
  alacritty = grahamc.alacritty;
  killFocused = kill-focused;
  freezeFocused = freeze-focused;
  guilauncher = grahamc.guilauncher;
  spawn = grahamc.spawn;
  waybar = waybar.override { pulseSupport = true; };

  sway_cycle_workspace = sway-cycle-workspace;
  waybar_conf = mutate ./waybar {
    inherit pavucontrol;
    inherit (grahamc) spawn;
  };

  bgimage = ../../nixos-nineish.png;

  guis = grahamc.guis;
}
