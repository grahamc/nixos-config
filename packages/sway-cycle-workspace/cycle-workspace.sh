#!/bin/sh

set -eux

PATH=@pkg_path@
# Cycle a workspace between outputs

new_workspace() (
    all_outputs=$(swaymsg -rt get_outputs | jq -r '.[] | .name' | sort)
    focused_output=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')

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
        | grep -A1 "$focused_output" \
        | head -n2 \
        | tail -n1
)

swaymsg move workspace to "$(new_workspace)"
