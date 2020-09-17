{ config, pkgs, ... }:
{
  systemd.user.timers.did-graham-commit-his-repos = {
    description = "Check if graham is being lazy about committing";
    partOf      = [ "did-graham-commit-his-repos.service" ];
    wantedBy    = [ "graphical-session.target" ];
    timerConfig.OnCalendar = "*:0/20";
  };

  systemd.user.services.did-graham-commit-his-repos = {
    enable = true;
    wantedBy = [ "graphical-session.target" ];

    unitConfig = {
      ConditionACPower = true;
      ConditionGroup = "users";
    };

    script = ''
      mkdir -p "''${XDG_CACHE_HOME:-$HOME/.cache}/shell-warning"
      ${pkgs.did-graham-commit-his-repos} $HOME /etc/nixos >  "''${XDG_CACHE_HOME:-$HOME/.cache}/shell-warning/git"
    '';
  };
}
