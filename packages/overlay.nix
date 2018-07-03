self: super:
{
  # No longer applies on 18.03:
  #autorandr = pkgs.autorandr.overrideAttrs (x: {
  #  patches = [ ./autorandr-configs/autorandr.patch ];
  #});

  autorandr-configs = self.callPackage ./autorandr-configs { };

  backlight = self.callPackage ./backlight { };

  custom-emacs = self.callPackage ./emacs { };

  dunst_config = self.callPackage ./dunst { };

  email = self.callPackage ./email { };

  gitconfig = self.callPackage ./gitconfig { };

  gnupgconfig = self.callPackage ./gnupgconfig { };

  i3config = self.callPackage ./i3config { };

  is-nix-channel-up-to-date = self.callPackage ./is-nix-channel-up-to-date { };

  kitty-conf = ./kitty.conf;

  motd-massive = self.callPackage ./motd { };

  mutate = self.callPackage ./mutate { };

  nixpkgs-maintainer-tools = self.callPackage ./nixpkgs-maintainer-tools { };

  nixpkgs-pre-push = self.callPackage ./nixpkgs-pre-push { };

  passff-host = self.callPackage ./passff-host { };

  timeout_tcl = self.callPackage ./timeout { };

  volume = self.callPackage ./volume { };
}
