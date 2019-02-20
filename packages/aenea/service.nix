{ pkgs, ... }: {
  systemd.user.services."aenea" = {
    description = "DNS Aenea";

    serviceConfig = {
      ExecStart = "${pkgs.aenea}/server.py";
    };
  };

  networking.firewall.interfaces.vboxnet0.allowedTCPPorts = [ 8240 ];
}
