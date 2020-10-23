#!/bin/sh

set -eux
program=$1

exec systemd-run --user --scope --unit "run-$(basename "$program")-$(uuidgen)" "$@"

