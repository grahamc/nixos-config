{ emacsPackagesNg, notmuch, mutate, msmtp, writeText, docbook5
  , graphviz, hunspellWithDicts, hunspellDicts, fetchFromGitHub
  , fetchpatch }:

let
  nix-mode-overrides = {
    none = x: {};

    master-floating = oldAttrs: {
      src = builtins.fetchGit {
        url = "https://github.com/nixos/nix-mode.git";
        ref = "master";
      };
    };

    master-2019-01-03 = oldAttrs: {
      src = builtins.fetchGit {
        url = "https://github.com/nixos/nix-mode.git";
        ref = "master";
        rev = "6445ebfad696bdfd1d7bc8ddd463772ba61763e8";
      };
    };

    ldlwork = oldAttrs: {
      src = builtins.getchGit {
        url = "https://github.com/dustinlacewell/nix-mode.git";
        rev = "b0829d67c542e2befec5136dac75f4a5470c5f05";
      };
    };

    etu-master-floating = oldAttrs: {
      src = builtins.fetchGit {
        url = "https://github.com/etu/nix-mode.git";
        ref = "master";
      };
    };
  };
in
emacsPackagesNg.emacsWithPackages (epkgs: (
  (with epkgs.melpaPackages; [
    artbollocks-mode
    fill-column-indicator
    editorconfig
    elm-mode
    erlang
    (nix-mode.overrideAttrs nix-mode-overrides.master-2019-01-03)
    markdown-mode
    yaml-mode
    rust-mode
    diff-hl
    python-mode
    php-mode
    js2-mode
    json-mode
    hcl-mode
    go-mode
    elixir-mode
    magit
    ghc
    flycheck
    graphviz-dot-mode
    yasnippet

    ivy
    counsel
    counsel-projectile
    projectile
    super-save
    swiper
  ])
  ++ [
    notmuch
    (emacsPackagesNg.trivialBuild {
      pname = "grahams-mode";
      version = "1970-01-01";
      src = mutate ./default.el {
        inherit msmtp graphviz;
        spelling = hunspellWithDicts ([hunspellDicts.en-us]);

        schemas = writeText "schemas.xml" ''
          <locatingRules xmlns="http://thaiopensource.com/ns/locating-rules/1.0">
            <documentElement localName="section" typeId="DocBook"/>
            <documentElement localName="chapter" typeId="DocBook"/>
            <documentElement localName="article" typeId="DocBook"/>
            <documentElement localName="book" typeId="DocBook"/>
            <typeId id="DocBook" uri="${docbook5}/xml/rng/docbook/docbookxi.rnc" />
          </locatingRules>
        '';

      };
    })
  ]
))
