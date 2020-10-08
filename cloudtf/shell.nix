let pkgs = import <nixpkgs> {}; in pkgs.mkShell {
  buildInputs = [
    (pkgs.terraform_0_12.withPlugins(p: [ p.aws ]))
  ];
}
