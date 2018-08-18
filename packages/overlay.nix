self: super:
{
  autorandr-configs = self.callPackage ./autorandr-configs { };

  backlight = self.callPackage ./backlight { };

  custom-emacs = self.callPackage ./emacs { };

  dunst_config = self.callPackage ./dunst { };

  email = self.callPackage ./email { };

  direnv-hook = self.callPackage ./direnv-hook { };

  gitconfig = self.callPackage ./gitconfig { };

  gnupgconfig = self.callPackage ./gnupgconfig { };

  i3config = self.callPackage ./i3config { };

  is-nix-channel-up-to-date = self.callPackage ./is-nix-channel-up-to-date { };

  motd-massive = self.callPackage ./motd { };

  mutate = self.callPackage ./mutate { };

  nixpkgs-maintainer-tools = self.callPackage ./nixpkgs-maintainer-tools { };

  nixpkgs-pre-push = self.callPackage ./nixpkgs-pre-push { };

  passff-host = self.callPackage ./passff-host { };

  timeout_tcl = self.callPackage ./timeout { };

  volume = self.callPackage ./volume { };

  nix = super.nix.overrideAttrs (x: {
    patches = (x.patches or []) ++ [
      (self.fetchpatch {
        url = "https://github.com/grahamc/nix/commit/6a7ede9b6c8f7c172ae8879f35bdb8cc4c258974.patch";
        sha256 = "0mdqa9w1p6cmli6976v4wi0sw9r4p5prkj7lzfd1877wk11c9c73";
      })
      (self.fetchpatch {
        url = "https://github.com/grahamc/nix/commit/7d43d359.patch";
        sha256 = "0mdqa9w1p6cmli6976v4wi0sw9r4p5prkj7lzfd1876wk11c9c73";
      })


    ];
  });
}
