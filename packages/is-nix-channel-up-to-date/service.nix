{ config, pkgs, ... }:
{
# note this doesn't really work right


  users = {
    users.is-nix-channel-up-to-date = {
      description = "Is-Nix-Channel-Up-To-Date";
      home = "/var/lib/is-nix-channel-up-to-date";
      createHome = true;
      group = "is-nix-channel-up-to-date";
      uid = 400;
    };

    groups.is-nix-channel-up-to-date.gid = 400;
  };

  systemd.services.is-nix-channel-up-to-date = {
    enable = true;
    after = [ "network.target" "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    environment.VERSION_LOCAL = config.system.nixosRevision;
    path = with pkgs; [ curl coreutils ];

    serviceConfig = {
      User = "is-nix-channel-up-to-date";
      Group = "is-nix-channel-up-to-date";
      PrivateTmp = true;
      WorkingDirectory = "/var/lib/is-nix-channel-up-to-date";
    };

    preStart = ''
      chmod 755 /var/lib/is-nix-channel-up-to-date
    '';
    script = toString pkgs.is-nix-channel-up-to-date;
  };
}
