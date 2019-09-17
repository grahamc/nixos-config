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
  '';

  networking.wireguard.interfaces."${interface}" = secrets.wireguard;
  systemd.services = mapToAttrs (peer: {
    name = "ensure-${interface}-peer-${keyToUnitName peer.publicKey}";
    value = {
      wantedBy = [ "multi-user.target" ];
      script = ''
        systemctl start ${escapeShellArg (peerUnitName interface peer)}
      '';
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  }) (builtins.filter (peer: peer ? endpoint) secrets.wireguard.peers);
}
