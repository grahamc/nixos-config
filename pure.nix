let
  nixpkgs = builtins.fetchGit {
    url = "https://github.com/nixos/nixpkgs.git";
    rev = "b37872d4268164614e3ecef6e1f730d48cf5a90f";
    ref = "master";
  };

  config = ./.;

  myconfig = import "${nixpkgs}/nixos" {
    configuration = "${config}/main-configuration.nix";
    system = "x86_64-linux";
  };
in myconfig
