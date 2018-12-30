#!/bin/sh

# Redirect all stdout output to stderr
# but create a third pipe which lets us print to stdout
#
# If this program were to run after the execs:
#
#    echo "stdout" >&1
#    echo "stderr" >&2
#    echo "third" >&3
#
# "stdout" and "stderr" would go to stderr, and "third"
# would go to stdout.

set -euo pipefail

exec 3>&1
exec 1>&2

emit() {
    echo "$@" >&3
}

no_lines() {
    lines=$(cat | wc -l)
    [ "$lines" -eq 0 ]
}

main() {
    PATH=@git@/bin:@coreutils@/bin:$PATH
    repo=$(dirname "$1")

    if [ "$(basename "$1")" != ".git" ]; then
        emit "not .git: $1"
        exit 1
    fi

    export GIT_DIR="$1"
    export GIT_WORK_TREE="$repo"

    flags=""
    flag() {
        if [ "x$flags" = "x" ]; then
            flags="$1"
        else
            flags="$1,$flags"
        fi
    }

    if ! git diff --exit-code --quiet HEAD --; then
        flag "dirty"
    fi

    if ! git ls-files --others --exclude-standard | no_lines; then
        flag "untracked"
    fi

    if [ "x$flags" != "x" ]; then
        emit "$flags $GIT_WORK_TREE"
    fi
}
main "$@"
