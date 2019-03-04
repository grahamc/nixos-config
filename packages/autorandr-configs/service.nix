{ pkgs, ... }: {
  # this never worked
  #services.udev.extraRules = ''
  #  ACTION=="change", SUBSYSTEM=="drm" TAG+="systemd"
  #'';
  #, ENV{SYSTEMD_USER_WANTS}="hello.service"
  #, KERNEL=="card0-DP-2",

  systemd.user.targets.docked = {
    wants = [ "autorandr@docked-home.service" ];
  };

  systemd.user.targets.undocked = {
    wants = [ "autorandr@undocked.service" ];
  };

  systemd.user.services."autorandr@" = {
    description = "Autorandr execution hook";

    serviceConfig = {
      StartLimitInterval = 5;
      StartLimitBurst = 1;
      ExecStart = "${pkgs.autorandr}/bin/autorandr -l %i";
      Type = "oneshot";
      RemainAfterExit = false;
      Environment = [
        "XDG_CONFIG_HOME=${pkgs.autorandr-configs}"
        "XDG_CONFIG_DIRS="
      ];
    };
  };
}
