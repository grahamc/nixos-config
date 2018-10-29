{ config, pkgs, ... }:
{
  systemd.services.loginctl-trigger-lock-on-sleep = {
    before = [ "sleep.target" ];
    wantedBy = [ "sleep.target" ];
    script = "loginctl lock-sessions";
  };

  systemd.user.services.lock-screen-hook = {
    wantedBy = [ "graphical-session.target" ];
    script = ''
      ${pkgs.systemd-lock-handler} ${pkgs.i3lock}/bin/i3lock -fi ${pkgs.nixos-artwork.wallpapers.gnome-dark}/share/artwork/gnome/nix-wallpaper-simple-dark-gray_bottom.png
    '';
  };
}
