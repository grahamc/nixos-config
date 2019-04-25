{ pkgs, ... }: {
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", TAG+="systemd", ENV{SYSTEMD_WANTS}="recognize-thunderbolt.service"
  '';

  systemd.services."recognize-thunderbolt" = {
    enable = true;
    serviceConfig = {
      ExecStart = "${pkgs.recognize-thunderbolt}/bin/recognize-thunderbolt";
      Type = "oneshot";
      RemainAfterExit = false;
    };
  };
}
