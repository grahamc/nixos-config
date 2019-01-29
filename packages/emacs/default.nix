{ emacsPackagesNg, notmuch, mutate, msmtp, writeText, docbook5
  , graphviz, hunspellWithDicts, hunspellDicts, fetchFromGitHub
  , fetchpatch, nixosUnstablePkgs }:

let
  nix-mode-overrides = {
    none = x: {};

    local-clone = oldAttrs: {
      src = /home/grahamc/projects/nixos/nix-mode;
    };

    master-floating = oldAttrs: {
      src = builtins.fetchGit {
        url = "https://github.com/nixos/nix-mode.git";
        ref = "master";
      };
    };

    master-2019-01-29 = oldAttrs: {
      src = builtins.fetchGit {
        url = "https://github.com/nixos/nix-mode.git";
        ref = "master";
        rev = "1e53bed4d47c526c71113569f592c82845a17784";
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
    counsel
    counsel-projectile
    diff-hl
    direnv
    editorconfig
    elixir-mode
    elm-mode
    erlang
    fill-column-indicator
    flycheck
    ghc
    go-mode
    graphviz-dot-mode
    hcl-mode
    ivy
    js2-mode
    json-mode
    magit
    markdown-mode
    (nix-mode.overrideAttrs nix-mode-overrides.master-2019-01-29)
    php-mode
    projectile
    python-mode
    rust-mode
    super-save
    swiper
    yaml-mode
    yasnippet
  ])
  ++ (with (nixosUnstablePkgs.emacsPackagesNgFor emacsPackagesNg.emacs); [
    lsp-mode
    lsp-ui
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
