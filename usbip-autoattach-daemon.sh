#!/usr/bin/env bash
# Daemon which periodically polls the list of host USB devices (wsl-list-host-usb.sh) for unattached devices.
# Attaches any device with matching VID:PID
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

SLEEP_TIME=10

# Loop forever
while true; do
    # Discover all unattached NXTs; collect an array of BUS ID attributes for those devices
    BUS_IDS=($( \
        ./wsl-list-host-usb.sh | \
        grep -x -e ".*$NXT_NORMAL_MODE.*Not attached.*" \
                -e ".*$NXT_SAMBA_MODE.*Not attached.*" | \
        while read -r DEVICE_DESC; do
            read BUS_ID _ <<< "$DEVICE_DESC"
            echo $BUS_ID
        done
    ))

    # Attach each NXT by its unique BUS ID
    for BUS_ID in "${BUS_IDS[@]}"; do
        echo "Attaching NXT on BUS_ID=$BUS_ID"
        ./wsl-attach-host-usb.sh "$BUS_ID" 
    done

    sleep $SLEEP_TIME

done
