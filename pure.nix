let
  nixpkgs = builtins.fetchGit {
    url = "/home/grahamc/projects/nixpkgs";
    rev = "e2b5d5311ba59b6ae4619f6e5d5905e52d74df40";
    ref = "fixup-pure";
  };

  config = ./.;

  myconfig = import "${nixpkgs}/nixos" {
    configuration = (import config);
    system = "x86_64-linux";
  };
in myconfig
