{}:
import
  (builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs-channels.git";
    rev = "190727db4ea7e0d083e7dbcb66ced11f31b340f0"; # nixos-unstable as of 2019-01-24
  })
  {}
