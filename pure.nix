let
  nixpkgs = builtins.fetchGit {
    url = "https://github.com/nixos/nixpkgs.git";
    rev = "b37872d4268164614e3ecef6e1f730d48cf5a90f";
    ref = "master";
  };

  config = builtins.fetchGit {
    url = "/etc/nixos";
    rev ="b35f7798dbb5e2e234d1d21cb0f16aa60ce1f361";
  };

  myconfig = import "${nixpkgs}/nixos" {
    configuration = "${config}/main-configuration.nix";
    system = "x86_64-linux";
    localSystem = "x86_64-linux";
  };
in myconfig
