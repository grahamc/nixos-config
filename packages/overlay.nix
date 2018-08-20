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
        url = "https://github.com/grahamc/nix/commit/36d9a243f73c7b3c41a0f75a079731577cdb52c4.patch";
        sha256 = "1a5rpb2wid6yfwz82wdz74w8lsjp6lxvhgdm2mf756a3s2qzgg7n";
      })
      (self.fetchpatch {
        url = "https://github.com/grahamc/nix/commit/0fe3ea0b31557b068a536515fd1700871c0fe880.patch";
        sha256 = "0r0bmvf5zdphabzrcffw8anrzvq6zjykp4sj057dx1xy3ykvjwx0";
      })
    ];
  });

  virtualbox = self.virtualboxWithExtpack;
}
