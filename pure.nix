let
  nixpkgs = builtins.fetchGit {
    url = "https://github.com/nixos/nixpkgs.git";
    rev = "b37872d4268164614e3ecef6e1f730d48cf5a90f";
    ref = "master";
  };

  config = builtins.fetchGit {
    url = "/etc/nixos";
    rev ="9756fb30e072f5e5747e82012dc49a519f5c14d4";
  };

  myconfig = import "${nixpkgs}/nixos" {
    configuration = "${config}/main-configuration.nix";
    system = "x86_64-linux";
  };
in myconfig
