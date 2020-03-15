{ callPackage }:
let
  src = builtins.fetchGit {
    url = "https://github.com/grahamc/resholved";
    ref = "master";
    rev = "a739fa1f3afaec26f1b1677568e64af22ed68697";
  };
in callPackage src {}
