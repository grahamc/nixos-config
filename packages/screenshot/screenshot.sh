#!@bash@/bin/bash

PATH="@coreutils@/bin:@scrot@/bin:@libnotify@/bin:@openssh@/bin:@xclip@/bin:@utillinux@/bin"

set -eux
set -o pipefail

LOCAL_DIR=~/Screenshots
REMOTE_SCP=gsc.io:/home/grahamc/gsc.io/public/scratch
REMOTE_HTTP=http://gsc.io/scratch

timestamp() {
    TZ=utc date '+%Y-%m-%dT%H:%M:%SZ'
}

filename() {
    echo "$(timestamp)-$1-$(uuidgen).png"
}

snapshot() {
    # with a png, 1 means highly compressed, not actually low quality
    QUALITY=1
    scrot \
        --quality "$QUALITY" \
        "$@"
}

main() {
    mkdir -p "$LOCAL_DIR"
    cd "$LOCAL_DIR"

    mode=$1

    case "$mode" in
        full-screen)
            dest=$(filename "full-screen")
            snapshot "$dest"
            ;;
        select)
            dest=$(filename "selection")
            snapshot --border --select "$dest"
            ;;
        *)
            echo "?? mode: $mode" >&2
            exit 1
            ;;
    esac

    notify-send "Screenshot taken at $dest! :)"
    if scp "$LOCAL_DIR/$dest" "$REMOTE_SCP/$dest"; then
        url="$REMOTE_HTTP/$dest"
        echo "$url" | xclip -in -selection clipboard
        notify-send "Screenshot uploaded to $url, and has been copied to your clipboard"
    else
        notify-send "Uploading  $LOCAL_DIR/$dest to $REMOTE_SCP/$dest failed"
    fi
}

main "$1"
