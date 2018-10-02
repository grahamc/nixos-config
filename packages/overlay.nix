self: super:
{
  autorandr-configs = self.callPackage ./autorandr-configs { };

  backlight = self.callPackage ./backlight { };

  custom-emacs = self.callPackage ./emacs { };

  cnijfilter2 = super.cnijfilter2.overrideAttrs (x: {
    name = "cnijfilter2-5.60";
    src = self.fetchzip {
      url = "http://gdlp01.c-wss.com/gds/0/0100009490/01/cnijfilter2-source-5.60-1.tar.gz";
      sha256 = "0yagz840g28kz0cyy3abbv4h2imw1pia1hzsqacjsmvz4wdhy14k";
    };
  });

  dunst_config = self.callPackage ./dunst { };

  email = self.callPackage ./email { };

  direnv-hook = self.callPackage ./direnv-hook { };

  gitconfig = self.callPackage ./gitconfig { };

  gnupgconfig = self.callPackage ./gnupgconfig { };

  i3config = self.callPackage ./i3config { };

  is-nix-channel-up-to-date = self.callPackage ./is-nix-channel-up-to-date { };

  did-graham-commit-his-repos = self.callPackage ./did-graham-commit-his-repos { };

  motd-massive = self.callPackage ./motd { };

  mutate = self.callPackage ./mutate { };

  nixpkgs-maintainer-tools = self.callPackage ./nixpkgs-maintainer-tools { };

  nixpkgs-pre-push = self.callPackage ./nixpkgs-pre-push { };

  passff-host = self.callPackage ./passff-host { };

  timeout_tcl = self.callPackage ./timeout { };

  volume = self.callPackage ./volume { };
}
