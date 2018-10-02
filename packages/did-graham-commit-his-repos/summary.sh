#!/bin/sh

PATH=@findutils@/bin:@coreutils@/bin:@gnused@/bin

lines=$(find "$@" \
    -mindepth 1 \
    -type d -name .git -print0 \
    -o -name '.*' -prune \
  | xargs -0 -n1 -P"$(nproc)" @checker@ 2> /dev/null \
  | sed -e 's/^/ - /')

if [ "x$lines" != "x" ]; then
  echo "The following repositories have uncommitted stuff:"
  echo "$lines"
fi
