{ secrets }:
{ lib, ... }:
let
  inherit (lib) replaceChars escapeShellArg;
  mapToAttrs = f: l: builtins.listToAttrs (map f l);
  interface = "wg0";
  keyToUnitName = replaceChars
    [ "/" "-"    " "     "+"     "="      ]
    [ "-" "\\x2d" "\\x20" "\\x2b" "\\x3d" ];

   peerUnitName = interfaceName: peer:
    let
      unitName = keyToUnitName peer.publicKey;
    in "wireguard-${interfaceName}-peer-${unitName}";
in {
  networking.extraHosts = ''
    10.10.2.15 ogden # wireguard now
    10.10.2.16 kif
  '';

  networking.wireguard.interfaces."${interface}" = secrets.wireguard;
  networking.nameservers = [ "4.2.2.2" "4.2.2.3" ];
  systemd.services = mapToAttrs (peer: {
    name = "ensure-${interface}-peer-${keyToUnitName peer.publicKey}";
    value = {
      wantedBy = [ "multi-user.target" ];
      script = ''
        systemctl start ${escapeShellArg (peerUnitName interface peer)}
      '';
      serviceConfig = {
        RemainAfterExit = true;
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  }) (builtins.filter (peer: peer ? endpoint) secrets.wireguard.peers);
}
