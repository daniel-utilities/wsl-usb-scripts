#!/usr/bin/env bash

IFS=$'\n'
DEVICE_MATCH_SUBSTRINGS=($DEVICE_MATCH_SUBSTRINGS)

echo "Please edit /etc/defaults/usb-autoattach to specify device regex strings."
echo "Will autoattach USB devices containing the following strings:"
for SUBSTRING in ${DEVICE_MATCH_SUBSTRINGS[@]}; do
    echo "  $SUBSTRING"
done

while true; do
    # Poll host's USB devices; only consider those that are "Not attached"
    IFS=$'\n'
    UNATTACHED_DEVICES=($(usbip-list | grep -x -s ".*Not attached.*" | cat ))

    # For each unattached device, check if any of them contain a substring from the list
    for DEVICE in ${UNATTACHED_DEVICES[@]}; do
        # echo "Found unattached device: $DEVICE"

        for SUBSTRING in ${DEVICE_MATCH_SUBSTRINGS[@]}; do
            # echo "Checking against \"$SUBSTRING\""
            if [[ "$DEVICE" == *"$SUBSTRING"* ]]; then
                BUS_ID=$(echo "$DEVICE" | sed -e 's/^[[:space:]]*//' -e 's/\s.*$//')
                echo "Found device matching \"$SUBSTRING\" on BUS_ID=$BUS_ID."
                usbip-attach "$BUS_ID" 
                break 
            fi
        done
    done

    sleep $POLL_INTERVAL

done
