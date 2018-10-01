{ config, pkgs, ... }:
{
# note this doesn't really work right


  users = {
    users.is-nix-up2date = {
      description = "Is-Nix-Channel-Up-To-Date";
      home = "/var/lib/is-nix-channel-up-to-date";
      createHome = true;
      group = "is-nix-up2date";
      uid = 400;
    };

    groups.is-nix-up2date.gid = 400;
  };

  systemd.timers.is-nix-channel-up-to-date = {
    description = "Update timer for locate database";
    partOf      = [ "update-locatedb.service" ];
    wantedBy    = [ "timers.target" ];
    timerConfig.OnCalendar = "*:0/7";
  };

  systemd.services.is-nix-channel-up-to-date = {
    enable = true;
    after = [ "network.target" "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [ curl coreutils ];

    unitConfig = {
      ConditionACPower = true;
      ConditionPathExists = "/var/lib/is-nix-channel-up-to-date/up-to-date";
    };

    serviceConfig = {
      User = "is-nix-up2date";
      Group = "is-nix-up2date";
      PrivateTmp = true;
      WorkingDirectory = "/var/lib/is-nix-channel-up-to-date";
    };

    preStart = ''
      chmod 755 /var/lib/is-nix-channel-up-to-date
    '';
    script = ''
      ${pkgs.is-nix-channel-up-to-date} \
        ${config.system.nixos.release} \
        ${config.system.nixos.revision} \
        /var/lib/is-nix-channel-up-to-date/up-to-date
    '';
  };

  system.activationScripts.up-to-date = ''
    touch /var/lib/is-nix-channel-up-to-date/up-to-date || true
    chown is-nix-up2date:is-nix-up2date /var/lib/is-nix-channel-up-to-date/up-to-date
  '';
}
