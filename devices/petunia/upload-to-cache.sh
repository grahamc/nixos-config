#!/bin/sh

set -eu

# Shift off arguments to the hook until the only remaining arguments
# are output paths
while [ "${1:---}" != "--" ]; do
    shift
done
shift # pop off the "--"

echo "Signing paths" "$@"
nix sign-paths --key-file /rpool/persist/etc/nix/key.secret "$@"
echo "Uploading paths" "$@"
exec nix copy --to 's3://example-nix-cache?region=eu-west-2' "$@"
