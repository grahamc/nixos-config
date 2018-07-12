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

  systemd.services.is-nix-channel-up-to-date = {
    enable = true;
    after = [ "network.target" "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    environment.VERSION_LOCAL = config.system.nixos.revision;
    path = with pkgs; [ curl coreutils ];

    serviceConfig = {
      User = "is-nix-up2date";
      Group = "is-nix-up2date";
      PrivateTmp = true;
      WorkingDirectory = "/var/lib/is-nix-channel-up-to-date";
    };

    preStart = ''
      chmod 755 /var/lib/is-nix-channel-up-to-date
    '';
    script = toString pkgs.is-nix-channel-up-to-date;
  };
}
