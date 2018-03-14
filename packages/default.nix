{
  nixpkgs = {
    config = {
      allowUnfree = true;
      packageOverrides = pkgs: rec {
        autorandr = pkgs.autorandr.overrideAttrs (x: {
          patches = [ ./autorandr-configs/autorandr.patch ];
        });

        autorandr-configs = pkgs.callPackage ./autorandr-configs { };

        backlight = pkgs.callPackage ./backlight { };

        custom-emacs = pkgs.callPackage ./emacs { };

        dunst_config = pkgs.callPackage ./dunst { };

        email = pkgs.callPackage ./email { };

        gitconfig = pkgs.callPackage ./gitconfig { };

        gnupgconfig = pkgs.callPackage ./gnupgconfig { };

        i3config = pkgs.callPackage ./i3config { };

        is-nix-channel-up-to-date = pkgs.callPackage ./is-nix-channel-up-to-date { };

        motd-massive = pkgs.callPackage ./motd { };

	      mutate = pkgs.callPackage ./mutate { };

        nixpkgs-maintainer-tools = pkgs.callPackage ./nixpkgs-maintainer-tools { };

        nixpkgs-pre-push = pkgs.callPackage ./nixpkgs-pre-push { };

        passff-host = pkgs.callPackage ./passff-host { };

        timeout_tcl = pkgs.callPackage ./timeout { };

        volume = pkgs.callPackage ./volume { };
      };
    };
  };
}
