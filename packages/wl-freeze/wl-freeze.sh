#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq shellcheck
# shellcheck shell=bash


set -eu

if [ -z "${NOT_BUFFERED:-}" ]; then
    export NOT_BUFFERED=1
    exec stdbuf -oL -eL bash "$0"
fi

err() {
    echo "$@" >&2
}

scope_cache=$(mktemp freezer.XXXX -t)
trap cleanup EXIT

cleanup() {
  local scope
  while read -r scope; do
    echo 0 > "$scope/cgroup.freeze" || true
  done < "$scope_cache"
  rm "$scope_cache"
}

scopedirforpid() {
    local pid=$1
    local scope

    scope=$(cut -d: -f3- "/proc/$pid/cgroup")
    if [ -z "$scope" ]; then
        err "Determining scope failed: empty. Too dangerous. Aborting."
        exit 1
    fi

    local cgroupdir="/sys/fs/cgroup/$scope"

    if [ ! -d "$cgroupdir" ]; then
        err "Determining my scope failed: not a dir: $cgroupdir"
        exit 1
    fi

    echo "$cgroupdir"
}


freezer() {
    local my_scopedir="$1"
    local last_scopedir=""
    local scope
    while read -r scope; do
        printf "Entering %s\n" "$scope"
        if [ -z "$last_scopedir" ]; then
            printf "\tprevious scope unknown\n"
            printf "\t=> not freezing\n"
        elif [ "$last_scopedir" == "$my_scopedir" ]; then
            printf "\tprevious scope was our protected scope\n"
            printf "\t=> not freezing\n"
        else
            printf "\tprevious scope: %s\n" "$last_scopedir"
            printf "\t=> freezing\n"

            # Race condition: if these processes are exiting, these
            # freeze files may no longer exist. Ignore failures.
            echo 1 > "$last_scopedir/cgroup.freeze"  || true
            echo "$last_scopedir" >> "$scope_cache"
        fi

        # Race condition: if these processes are exiting, these
        # freeze files may no longer exist. Ignore failures.
        echo 0 > "$scope/cgroup.freeze" || true
        sed -i "\_${scope}_d" "$scope_cache"
        last_scopedir="$scope"
    done
}

main() {
    # check if kernel parameter is set
    if ! grep -Fq "cgroup_no_v1=all" "/proc/cmdline"; then
      err "To use this script you have to set the kernel paramet 'cgroup_no_v1' to 'all'"
      err "Please add this to your kernel parameters:"
      printf '"cgroup_no_v1=all"'
      exit 2
    fi

    local myscopedir
    myscopedir=$(scopedirforpid "$PPID")
    echo "Will not freeze $myscopedir"

    swaymsg -m -t subscribe '["window"]' \
        | tee /dev/stderr \
        | jq '.container.pid' \
        | (while read -r pid; do scopedirforpid "$pid"; done) \
        | grep -E 'run-[[:alnum:]].*\.scope$' \
        | freezer "$myscopedir"

}


main
