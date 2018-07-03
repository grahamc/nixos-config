{ emacsPackagesNg, notmuch, mutate, msmtp, writeText, docbook5, graphviz, hunspellWithDicts, hunspellDicts }:
emacsPackagesNg.emacsWithPackages (epkgs: (
  (with epkgs.melpaPackages; [
    helm
    fill-column-indicator
    editorconfig
    elm-mode
    erlang
    nix-mode
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
