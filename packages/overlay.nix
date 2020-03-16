{ secrets }: self: super:
let
  upgradeOverride = package: overrides:
  let
    upgraded = package.overrideAttrs overrides;
    upgradedVersion = (builtins.parseDrvName upgraded.name).version;
    originalVersion =(builtins.parseDrvName package.name).version;

    isDowngrade = (builtins.compareVersions upgradedVersion originalVersion) == -1;

    warn = builtins.trace
      "Warning: ${package.name} downgraded by overlay with ${upgraded.name}.";
    pass = x: x;
  in (if isDowngrade then warn else pass) upgraded;

  upgradeReplace = package: upgraded:
  let
    upgradedVersion = (builtins.parseDrvName upgraded.name).version;
    originalVersion =(builtins.parseDrvName package.name).version;

    isDowngrade = (builtins.compareVersions upgradedVersion originalVersion) == -1;

    warn = builtins.trace
      "Warning: ${package.name} downgraded by overlay with ${upgraded.name}.";
    pass = x: x;
  in (if isDowngrade then warn else pass) upgraded;
in {

  abathur-resholved = self.callPackage ./abathur-resholved { };
  resholve = { src, inputs }: self.runCommand
    "${builtins.baseNameOf src}-resholved"
    {
      nativeBuildInputs = [ self.abathur-resholved ];
      SHELL_RUNTIME_DEPENDENCY_PATH = "${self.lib.makeBinPath inputs}";
    }
    ''
      resholver < ${src} > $out
    '';


  aenea = self.callPackage ./aenea { };


  alacritty = super.alacritty.overrideAttrs (x: {
    postPatch = ''
      substituteInPlace alacritty_terminal/src/config/mouse.rs \
        --replace xdg-open ${self.xdg_utils}/bin/xdg-open
    '';
  });

  autorandr-configs = self.callPackage ./autorandr-configs { };

  backlight = self.callPackage ./backlight { };

  bash-config = self.callPackage ./bash-config { };

  custom-emacs = self.callPackage ./emacs { };

  cnijfilter2 = super.cnijfilter2.overrideAttrs (x: {
    name = "cnijfilter2-5.60";
    src = self.fetchzip {
      url = "http://gdlp01.c-wss.com/gds/0/0100009490/01/cnijfilter2-source-5.60-1.tar.gz";
      sha256 = "0yagz840g28kz0cyy3abbv4h2imw1pia1hzsqacjsmvz4wdhy14k";
    };
  });

  dunst_config = self.callPackage ./dunst { };

  direnv-hook = self.callPackage ./direnv-hook { };

  font-b612 = self.callPackage ./b612-font { };

  gitconfig = self.callPackage ./gitconfig { };

  gnupgconfig = self.callPackage ./gnupgconfig { };

  h = self.callPackage ./h { };

  helvetica = self.callPackage ./helvetica { inherit secrets; };

  i3config = self.callPackage ./i3config { inherit secrets; };

  ifd = src: drv:
    # pretty bad but works on what I've used it for
    self.runCommand "${drv.name}-ifd" {
      inherit src;
      inp = drv;
      buildInputs = with self; [ findutils ];
    }
    ''
      mkdir -p $out
      find $inp -maxdepth 1 -print0 | xargs -0 -I {} ln -s {} $out/
      ln -s $src $out/ifd-src
    '';

  is-nix-channel-up-to-date = self.callPackage ./is-nix-channel-up-to-date { };

  did-graham-commit-his-repos = self.callPackage ./did-graham-commit-his-repos { };

  motd-massive = self.callPackage ./motd { };

  mutate = self.callPackage ./mutate { };

  nixosUnstablePkgs = self.callPackage ./nixos-unstable-packages { };

  nixpkgs-maintainer-tools = self.callPackage ./nixpkgs-maintainer-tools { };

  nixpkgs-pre-push = self.callPackage ./nixpkgs-pre-push { };

  pass = upgradeOverride super.pass ({ postFixup, ... }: {
    version = "1.7.4";
    src = self.fetchgit {
      url = "https://git.zx2c4.com/password-store.git";
      rev = "88936b11aff49e48f79842e4628c55620e0ad736";
      sha256 = "0hjb0zh94mda4xq20srba40mh3iww3gg45w3vaqyvplxiw08hqrq";
    };
    patches = [
      ./pass-0001-clip-support-single-binary-coreutils.patch
    ];
    postFixup = ''
      ${postFixup}

      wrapProgram $out/bin/pass \
        --prefix PATH : "${self.wl-clipboard}/bin"
    '';
  });
  passff-host = self.callPackage ./passff-host { };

  slack = super.slack.overrideAttrs ({ buildCommand ? null, ... }:
  if buildCommand == null then {} else {
    buildCommand = ''
      ${buildCommand}
      makeWrapper $out/lib/slack/slack $out/bin/slack \
        --prefix XDG_DATA_DIRS : $GSETTINGS_SCHEMAS_PATH \
        --prefix PATH : ${self.xdg_utils}/bin
    '';
  });

  swayconfig = self.callPackage ./swayconfig { inherit secrets; };

  sway-cycle-workspace = self.callPackage ./sway-cycle-workspace { };

  recognize-thunderbolt = self.callPackage ./recognize-thunderbolt { };

  redshift = super.redshift.overrideAttrs (old: {
    name = "redshift-wayland";
    src = self.fetchFromGitHub {
      owner = "minus7";
      repo = "redshift";
      rev = "420d0d534c9f03abc4d634a7d3d7629caf29b4b6";
      sha256 = "12dwb96i4pbny5s64k6k4f8k936xa41zvcjhv54wv0ax471ymls7";
    };
  });

  screenshot = self.callPackage ./screenshot { };

  systemd-lock-handler = self.callPackage ./systemd-lock-handler { };

  timeout_tcl = self.callPackage ./timeout { };

  ttf-console-font = self.callPackage ./ttf-console-font { };
  otf2bdf = self.callPackage ./otf2bdf { };

  volume = self.callPackage ./volume { };

  vault-plugin-secrets-oauthapp = self.callPackage ./vault-plugin-secrets-oauthapp {};
  vault-plugin-secrets-packet = self.buildGoModule {
    name = "vault-plugin-secrets-packet";
    version = "0.0.1";
    src = self.fetchFromGitHub {
      owner = "packethost";
      repo = "vault-plugin-secrets-packet";
      rev = "98287087cc5310b0cf9391769c84378d1e78a654";
      sha256 = "0mi22vb9s07x25w6kkljr811b8vv7hjfas9g4c8xncssd81s4z0s";
    };
    modSha256 = "1q8ba5krq8a920gyvhdq4k7g15wnvchdyk1k4pl470xmxbsxcmji";
    subPackages = [ "cmd/vault-plugin-secrets-packet" ];
  };

  zsh-config = self.callPackage ./zsh-config { };

  /*
  nix = super.nix.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      ./nix/0001-Add-a-post-build-hook.patch
      ./nix/0002-fixup-Add-a-post-build-hook.patch
      ./nix/0001-pipe-stdout-stderr-to-the-user.patch
      ./nix/0001-use-a-stderr-sink-too.patch
      ];
  });*/
}
