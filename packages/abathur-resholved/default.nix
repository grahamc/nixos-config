{ callPackage }:
let
  src = builtins.fetchGit {
    url = "https://github.com/abathur/resholved";
    ref = "master";
    rev = "1a7144b2ea831b75cad0af3482c3fae04e705577";
  };
in
(callPackage src {}).resholved
