{ sources ? import ./sources.nix, config ? {} }:
with
{
  overlay = self: super:
    {
      overlayed = {
        niv = import sources.niv {};
        crate2nix = import sources.crate2nix {};
      };
    };
};
import sources.nixpkgs {
  overlays = [ overlay ];
  inherit config;
}
