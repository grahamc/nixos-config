#!/bin/sh

nix-build --pure-eval -E 'let r = (builtins.fetchGit { rev = "'$(git rev-parse HEAD)'"; url = ./.; }); in import "${r}/pure.nix"' -A system --show-trace
