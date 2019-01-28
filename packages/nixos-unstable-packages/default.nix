{}:
import
  (builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs-channels.git";
    rev = "bc41317e24317b0f506287f2d5bab00140b9b50e"; # nixos-unstable as of 2019-01-24
  })
  {}
