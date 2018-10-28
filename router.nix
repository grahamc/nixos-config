{ pkgs, ... }:
{
  services.unifi.enable = true;

  networking.interfaces."enp0s20f0u2" = {
    ipv4.addresses = [{
      address = "10.8.8.1";
      prefixLength = 24;
    }];
  };

  services.dhcpd4 = {
    enable = true;
    interfaces = [
      "enp0s20f0u2"
    ];
    extraConfig = ''
      subnet 10.8.8.0 netmask 255.255.255.0 {
        option subnet-mask 255.255.255.0;
        option broadcast-address 10.8.8.255;
        option routers 10.8.8.1;
        range 10.8.8.100 10.8.8.200;
      }
    '';
  };

  services.nginx = {
    enable = true;
    virtualHosts."example" = {
      root = pkgs.writeTextDir "index.html" "hi";
    };
  };

  networking.nat = {
    enable = true;
    externalInterface = "wlp2s0";
    internalInterfaces = [
      "enp0s20f0u2"
    ];
  };

  boot = {
    kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.conf.default.forwarding" = 1;
    };
  };
}
