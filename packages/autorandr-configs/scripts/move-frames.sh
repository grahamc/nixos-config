#!/bin/sh

set -eux

export PATH=@binpath@


function external_space() {
    i3-msg -t get_outputs \
        | jq -r '.[]
            | select((.name == "HDMI1" or .name == "DP1-1") and .active == true)
            | .current_workspace'
}

# When plugging in the external monitor, i3 will always give it a
# workspace, with nothing on it. Figure out what it is, so we can use
# it as a jumping off point to access other workspaces on that monitor
i=0
while : ; do
    monitor_space="$(external_space)"

    if [ "$monitor_space" == "" ]; then
        if [ $i -gt 30 ]; then
            echo "failed to find the new monitor :("
            exit 1
        fi
        i=$((i + 1))
        sleep .5;
    else
        break
    fi
done

# Find two unused workspaces which we can use as "scratch" workspaces,
# one for each display
readonly max_workspace=$(i3-msg -t get_workspaces | jq '.[] .num' | sort -nr | uniq | head -n1)
readonly laptop_scratch_workspace=$((max_workspace + 1))
readonly monitor_scratch_workspace=$((laptop_scratch_workspace + 1))

function move_to_other_monitor() {

    source_workspace="$1"

    # Create an empty scratch workspace on the monitor side, first by
    # moving the focus to the monitor side, then jumping to a new
    # workspace (the scratch workspace) on the monitor
    echo "workspace $monitor_space";
    echo "workspace $monitor_scratch_workspace";

    # Return to the source workspace which we're moving to the monitor
    echo "workspace $source_workspace";

    # Select all of the windows on the source... a bit janky-like, but
    # since I3 supports nested containers of windows, focus on parents
    # a few times to "ensure" we're at the top. I only use like 2 max
    # so this should be fine.
    echo "focus parent";
    echo "focus parent";
    echo "focus parent";
    echo "focus parent";
    echo "focus parent";

    # Move all the windows to the scratch space on the monitor,
    # so now the laptop is still on workspace SOURCE but all the
    # windows from SOURCE are now on the monitor's SCRATCH
    echo "move container to workspace $monitor_scratch_workspace";

    # Leave the source workspace on the laptop
    # Now, nothing should be on the SOURCE workspace's number,
    # allowing it to be recreated on the monitor side
    echo "workspace $laptop_scratch_workspace"

    # Focus on the monitor's SCRATCH workspace so that the next `move`
    # command will create the SOURCE workspace again on the monitor
    echo "workspace $monitor_scratch_workspace"

    # Select everything on the scratch workspace
    echo "focus parent";
    echo "focus parent";
    echo "focus parent";
    echo "focus parent";
    echo "focus parent";

    # move them to the SOURCE workspace, which will be allocated on
    # the monitor
    echo "move container to workspace $source_workspace";

    # focus back again in to the SOURCE workspace
    echo "workspace $source_workspace"
}

function srcs() {
    i3-msg -t get_workspaces | jq -r '.[] | select(.output == "eDP1") | .num'
}

for space in $(srcs); do
    i3-msg "$(move_to_other_monitor "$space" | tr '\n' ';')"
done
