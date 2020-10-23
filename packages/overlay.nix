{ secrets }: self: super:
let
  upgradeOverride = package: overrides:
    let
      upgraded = package.overrideAttrs overrides;
      upgradedVersion = (builtins.parseDrvName upgraded.name).version;
      originalVersion = (builtins.parseDrvName package.name).version;

      isDowngrade = (builtins.compareVersions upgradedVersion originalVersion) == -1;

      warn = builtins.trace
        "Warning: ${package.name} downgraded by overlay with ${upgraded.name}.";
      pass = x: x;
    in
      (if isDowngrade then warn else pass) upgraded;

  upgradeReplace = package: upgraded:
    let
      upgradedVersion = (builtins.parseDrvName upgraded.name).version;
      originalVersion = (builtins.parseDrvName package.name).version;

      isDowngrade = (builtins.compareVersions upgradedVersion originalVersion) == -1;

      warn = builtins.trace
        "Warning: ${package.name} downgraded by overlay with ${upgraded.name}.";
      pass = x: x;
    in
      (if isDowngrade then warn else pass) upgraded;
in
{
  abathur-resholved = self.callPackage ./abathur-resholved {};
  resholve = { src, inputs, allow ? {} }: self.runCommand
    "${builtins.baseNameOf src}-resholved"
    {
      nativeBuildInputs = [ self.abathur-resholved ];
      #SHELL_RUNTIME_DEPENDENCY_PATH = "${self.lib.makeBinPath inputs}";
      RESHOLVE_PATH = "${self.lib.makeBinPath inputs}";
      RESHOLVE_ALLOW = toString
        (self.lib.mapAttrsToList (name: value: map (y: name + ":" + y) value) allow);
    }
    ''
      resholver < ${src} > $out
      chmod --reference=${src} $out
    '';


  aenea = self.callPackage ./aenea {};


  #alacritty = super.alacritty.overrideAttrs (x: {
  #  postPatch = ''
  #    substituteInPlace alacritty_terminal/src/config/mouse.rs \
  #      --replace xdg-open ${self.xdg_utils}/bin/xdg-open
  #  '';
  #});

  autorandr-configs = self.callPackage ./autorandr-configs {};

  backlight = self.callPackage ./backlight {};

  backlight-locker = self.callPackage ./backlight-locker {};

  bash-config = self.callPackage ./bash-config {};

  custom-emacs = self.callPackage ./emacs {};

  cnijfilter2 = super.cnijfilter2.overrideAttrs (
    x: {
      name = "cnijfilter2-5.60";
      src = self.fetchzip {
        url = "http://gdlp01.c-wss.com/gds/0/0100009490/01/cnijfilter2-source-5.60-1.tar.gz";
        sha256 = "0yagz840g28kz0cyy3abbv4h2imw1pia1hzsqacjsmvz4wdhy14k";
      };
    }
  );

  dunst_config = self.callPackage ./dunst {};

  direnv-hook = self.callPackage ./direnv-hook {};

  font-b612 = self.callPackage ./b612-font {};

  gitconfig = self.callPackage ./gitconfig {};

  gnupgconfig = self.callPackage ./gnupgconfig {};

  networkmanager-openconnect = super.networkmanager-openconnect.overrideAttrs
    ({ patches ? [], ... }: {
      # patches =  patches ++ [ ./0001-Pass-explicitly-resolved-IP-port.patch ];
    });


  grahamc = {
    alacritty = self.grahamc.binWithPath "${self.alacritty}/bin/alacritty" [
      (self.grahamc.guiduckAlias "firefox")
      self.custom-emacs
      self.direnv
      self.file
      self.git
      self.gitAndTools.git-absorb
      self.gnupg
      self.h
      self.nixpkgs-fmt
      self.nixpkgs-maintainer-tools
      self.pass
      self.ripgrep
      self.xdg_utils
    ];

    guilauncher = self.callPackage ./guilauncher {};

    guis = self.buildEnv {
      name = "grahams-guis";
      pathsToLink = [ "/bin" ];
      extraOutputsToInstall = [ "bin" ];
      paths = [
        self.google-chrome
        self.slack
        (self.grahamc.pick self.firefox-wayland "bin/firefox")

        (self.grahamc.pick self.custom-emacs "bin/emacs")
        (self.grahamc.pick self.pavucontrol "bin/pavucontrol")
        (
          self.grahamc.binWithPath "${self.vscodium}/bin/codium"
            [
              self.git
              self.direnv
              self.lorri
              self.coreutils
              self.bash
            ]
        )
      ];
    };

    pick = src: path: self.runCommand "picked" {} ''
      mkdir -p "$(dirname "$out/${path}")"
      test -f "${src}/${path}"
      ln -s "${src}/${path}" "$out/${path}"
    '';

    binWithPath = bin: bins: self.runCommand "bin-with-path" {
      nativeBuildInputs = [ self.makeWrapper ];
    } ''
      mkdir -p $out/bin
      test -f "${bin}"
      makeWrapper "${bin}" \
        "$out/bin/$(basename "${bin}")" \
        --prefix PATH : ${self.lib.makeBinPath bins}
    '';

    guiduck = (self.callPackage ./guiduck/Cargo.nix {}).rootCrate.build;
    guiduckAlias = name: self.writeScriptBin name ''
      #! ${self.runtimeShell}
      exec -a "${name}" ${self.grahamc.guiduck}/bin/send "$@"
    '';

    snoop = self.callPackage ./snoop {};
    snoopedosh = self.grahamc.snoop "${self.oil}/bin/osh";

    nixos-software-manager = self.callPackage ./nixos-software-manager {};

    spawn = self.callPackage ./spawn {};
 };

  h = self.callPackage
    ./h
    {};

  helvetica = self.callPackage
    ./helvetica
    { inherit secrets; };

  # hplip = super.hplip.override { pythonPackages = self.python3Packages; };

  i3config = self.callPackage
    ./i3config
    { inherit secrets; };

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

  is-nix-channel-up-to-date = self.callPackage
    ./is-nix-channel-up-to-date
    {};

  # emacs26 = self.callPackage ../../../github.com/masm11/default.nix {    inherit super; };

  did-graham-commit-his-repos = self.callPackage
    ./did-graham-commit-his-repos
    {};

  kill-focused = self.callPackage ./kill-focused {};

  wl-freeze = self.callPackage ./wl-freeze {};

  motd-massive = self.callPackage
    ./motd
    {};

  mutate = self.callPackage
    ./mutate
    {};

  mako = upgradeOverride
    super.mako
    (
      { mesonFlags ? [], ... }: {
        version = "1.4.1";
        mesonFlags = [ "-Dsystemd=disabled" ];
        src = self.fetchFromGitHub {
          owner = "emersion";
          repo = "mako";
          rev = "db900e5db099d1f2d4566389dc54302835336678";
          sha256 = "1z40lwc7csvqvj21zk082bqlqaa7vvncynvn48xfvabxg8k5nx1w";
        };
      }
    );

  nixosUnstablePkgs = self.callPackage
    ./nixos-unstable-packages
    {};

  nixpkgs-maintainer-tools = self.callPackage
    ./nixpkgs-maintainer-tools
    {};

  nixpkgs-pre-push = self.callPackage
    ./nixpkgs-pre-push
    {};

  oil = super.oil.overrideAttrs ({ ... }: {
    version = "0.8.1";
    src = self.fetchurl {
      url = "https://www.oilshell.org/download/oil-0.8.1.tar.xz";
      sha256 = "0mhzys1siry848v7swr1iv2wp329ksw0gpz1qd82fmlakml5brc1";
    };
  });

  pass = upgradeOverride
    super.pass
    (
      { postFixup, ... }: {
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
      }
    );
  passff-host = self.callPackage
    ./passff-host
    {};

  slack = super.slack.overrideAttrs
    (
      { buildCommand ? null, ... }:
        if buildCommand == null then {} else {
          buildCommand = ''
            ${buildCommand}
            makeWrapper $out/lib/slack/slack $out/bin/slack \
              --prefix XDG_DATA_DIRS : $GSETTINGS_SCHEMAS_PATH \
              --prefix PATH : ${self.xdg_utils}/bin
          '';
        }
    );


  sway-unwrapped = self.enableDebugging super.sway-unwrapped;
  /*    (
      super.sway-unwrapped.overrideAttrs (
        { patches ? [], ... }: {
          patches = patches ++ [
            ./0001-swaynag-allow-specifying-more-buttons-which-execute-.patch
          ];
        }
      )
    );*/
  swaylock = self.enableDebugging
    super.swaylock;
    /*wlroots = super.wlroots.overrideAttrs
    (
      { ... }: {
        version = "0.10.0-plus-22-commits";
        src = self.fetchFromGitHub {
          owner = "swaywm";
          repo = "wlroots";
          rev = "273b280f469f5be3455f98f4230b169cc9ee67f2";
          sha256 = "1p0j30hnvcqbbak9bci3400vvxbwzhhzdv3sgwl190lzqxqq3q0g";
        };
      }
    );*/

  swayconfig = self.callPackage
    ./swayconfig
    { inherit secrets; };

  sway-cycle-workspace = self.callPackage
    ./sway-cycle-workspace
    {};

  recognize-thunderbolt = self.callPackage
    ./recognize-thunderbolt
    {};

  redshift = super.redshift.overrideAttrs
    (
      old: {
        name = "redshift-wayland";
        src = self.fetchFromGitHub {
          owner = "minus7";
          repo = "redshift";
          rev = "420d0d534c9f03abc4d634a7d3d7629caf29b4b6";
          sha256 = "12dwb96i4pbny5s64k6k4f8k936xa41zvcjhv54wv0ax471ymls7";
        };
      }
    );

  screenshot = self.callPackage
    ./screenshot
    {};

  systemd-lock-handler = self.callPackage
    ./systemd-lock-handler
    {};

  timeout_tcl = self.callPackage
    ./timeout
    {};

  ttf-console-font = self.callPackage
    ./ttf-console-font
    {};
  otf2bdf = self.callPackage
    ./otf2bdf
    {};

  volume = self.callPackage
    ./volume
    {};

  vault-plugin-secrets-oauthapp = self.callPackage
    ./vault-plugin-secrets-oauthapp
    {};
  vault-plugin-secrets-packet = self.buildGoModule
    {
      name = "vault-plugin-secrets-packet";
      version = "0.0.1";
      src = self.fetchFromGitHub {
        owner = "packethost";
        repo = "vault-plugin-secrets-packet";
        rev = "98287087cc5310b0cf9391769c84378d1e78a654";
        sha256 = "0mi22vb9s07x25w6kkljr811b8vv7hjfas9g4c8xncssd81s4z0s";
      };
      modSha256 = "1q8ba5krq8a920gyvhdq4k7g15wnvchdyk1k4pl470xmxbsxcmji";
      vendorSha256 = null;
      subPackages = [ "cmd/vault-plugin-secrets-packet" ];
    };

  zsh-config = self.callPackage
    ./zsh-config
    {};

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
