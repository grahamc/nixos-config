#!/bin/sh
PATH=@git@/bin:@coreutils@/bin
repo=$(dirname "$1")
if ! git --git-dir="$1" --work-tree="$repo" diff --exit-code --quiet HEAD --; then
    echo "$repo"
fi
