let
  makeTarget = type: other: {
    description = "On ${type} Power";
    conflicts = [ other ];
    unitConfig = {
      DefaultDependencies = false;
    };
  };
in {
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", KERNEL=="AC", ATTR{online}=="0", TAG+="systemd", ENV{SYSTEMD_WANTS}="battery.target", ENV{SYSTEMD_USER_WANTS}="battery.target"
    SUBSYSTEM=="power_supply", KERNEL=="AC", ATTR{online}=="1", TAG+="systemd", ENV{SYSTEMD_WANTS}="ac.target", ENV{SYSTEMD_USER_WANTS}="ac.target"
  '';

  systemd.targets.ac = makeTarget "AC" "battery.target";
  systemd.user.targets.ac = makeTarget "AC" "battery.target";
  systemd.targets.battery = makeTarget "Battery" "ac.target";
  systemd.user.targets.battery = makeTarget "Battery" "ac.target";
}
