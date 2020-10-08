{ pkgs, ... }:
let
  scratch = "/var/cache/nixos-software-manager";
  channel = "channel:nixos-20.09";
  nixos_config = "/home/grahamc/projects/grahamc/nixos-config/devices/petunia/configuration.nix";
in 
{
  systemd.tmpfiles.rules = [ "d ${scratch} 0755 root root -" ];

  systemd.services.stage-upgrade = {
    unitConfig = {
      # Not sure why I copy-pasted this from another module, but
      # I'd like this process to be killed if we leave ac.target.
      # Instead it seemed to stop immediately. Maybe this needs a
      # wantedBy or something.... but I don't want it to start
      # on every plug-in.
      # StopWhenUnneeded = true;

      # I was thinking I'd only stage one upgrade at a time, but
      # that could cause conditions where I upgrade and immediately
      # need to upgrade again, which would be annoying.       
      # ConditionPathExists = "!${scratch}/nixos-update-manager/system";
    };
    path = [ pkgs.gnutar pkgs.xz pkgs.git pkgs.openssh ];
    script = "${pkgs.grahamc.nixos-software-manager.stage-upgrade} ${channel} ${scratch}";
    environment.NIX_PATH = "nixos-config=${nixos_config}";
  };

  systemd.timers.stage-upgrade = {
    wantedBy = [ "ac.target" ];
    partOf = [ "ac.target" ];
    timerConfig.OnCalendar = "hourly";
    unitConfig = {
      StopWhenUnneeded = true;
    };
  };

  systemd.user.services.prompt-upgrade = {
    unitConfig = {
      ConditionPathExists = "${scratch}/nixos-update-manager/system";
      ConditionGroup = "users";

      # See comment for systemd.services.stage-upgrade for StopWhenUnneeded, and delete this
      # if that one doens't exist.
      # StopWhenUnneeded = true;
    };
    script = "${pkgs.grahamc.nixos-software-manager.prompt-upgrade} ${channel} ${scratch}";
    environment.XDG_SESSION_TYPE = "wayland";
  };

  systemd.user.timers.prompt-upgrade = {
    wantedBy = [ "ac.target" ];
    partOf = [ "ac.target" ];
    timerConfig.OnCalendar = "hourly";
    unitConfig = {
      StopWhenUnneeded = true;
    };
  };
}
