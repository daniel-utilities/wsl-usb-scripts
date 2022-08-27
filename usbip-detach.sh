#!/usr/bin/env bash

if [[ $# == 1 ]]; then
    BUSID=$1
else
    echo "USAGE:  usbip-detach BUSID"
    exit
fi

# If cmd.exe not on PATH, go find it
CMD="cmd.exe"
[[ ! $(type -P "cmd.exe") ]] && CMD="$(wslpath 'C:\Windows\System32\cmd.exe')"

# Sometimes need to run CMD from a windows directory for it to work
cd "$(wslpath 'C:\Windows\System32')"

"$CMD" /c usbipd wsl detach --busid $1

