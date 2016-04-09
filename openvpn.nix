let
  remote = builtins.readFile ./openvpn-server-clarify-prod;
in
{ config, ... }:
{
  services.openvpn.servers.clarify-prod = {
    autoStart = false;
    config = ''
      client
      dev tun
      proto udp
      remote ${remote}
      resolv-retry infinite
      nobind
      persist-key
      persist-tun
      key-direction 1
      comp-lzo
      verb 3
      auth-user-pass
      auth-nocache
      ca /root/vpn/cfy-prod/ca.crt
      cert /root/vpn/cfy-prod/cert.crt
      key /root/vpn/cfy-prod/key.key
      tls-auth /root/vpn/cfy-prod/ta.key
      reneg-sec 0
    '';
  };
}