#!/bin/sh

# Cycle a workspace between outputs

set -eu

if [ "x@pkg_path@" != "x" ]; then
    PATH=@pkg_path@
fi


currently_focused_output() (
    swaymsg -rt get_outputs | jq -r '.[] | select(.focused) | .name'
)

workspaces_on_other_screens() (
    current_output=$(currently_focused_output)
    swaymsg -rt get_workspaces | jq -r '.[] | select(.output != $output) | .name' --arg output "$current_output"
)

next_output() (
    workspace_name="$1"

    all_outputs=$(swaymsg -rt get_outputs | jq -r '.[] | .name' | sort)
    current_output=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.name == $name) | .output' --arg name "$workspace_name")

    # Print the list of all outputs twice, find the workspaces' current
    # output plus the following line, then get the second line -- which
    # will be the next workspace to try.
    #
    # If the workspace is on DP-3, and the output list is like:
    #
    #    DP-1
    #    DP-2
    #    DP-3
    #
    # Then we'll print:
    #
    #    DP-1
    #    DP-2
    #    DP-3
    #    DP-1
    #    DP-2
    #    DP-3
    #
    # and grep will find:
    #    DP-3
    #    DP-1
    #    DP-3
    #
    # and the head / tail combo will extract DP-1.
    #
    # On the next run when the workspace is on DP-1, we will still
    # print the same outputs:
    #
    #    DP-1
    #    DP-2
    #    DP-3
    #    DP-1
    #    DP-2
    #    DP-3
    #
    # and grep will find:
    #
    #    DP-1
    #    DP-2
    #    DP-1
    #    DP-2
    #
    # and head / tail will extract DP-2.
    printf "%s\n%s\n" "$all_outputs" "$all_outputs" \
        | grep -A1 "$current_output" \
        | head -n2 \
        | tail -n1
)

move_workspace() {
    swaymsg workspace "$1"
    swaymsg move workspace to output "$(next_output "$1")"
}

main() {
    if [ "${1:-x}" == "--all-to-focused" ]; then
        # Move all workspaces to the output currently focused
        dest_output=$(currently_focused_output)

        for workspace in $(workspaces_on_other_screens); do
            move_workspace "$workspace"
        done
    else
        # Move just the current workspace to the next output
        current_workspace=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .name')
        move_workspace "$current_workspace"
    fi
}

main "$@"
