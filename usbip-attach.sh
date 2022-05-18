#!/usr/bin/env bash

if [[ $# == 1 ]]; then
    BUSID=$1
else
    echo "USAGE:  usbip-attach BUSID"
    exit
fi

# Find where this script is located
CURRENT_DIR=$PWD
SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )


# Copy the helper batch file to a temporary directory in Windows
WIN_TEMP="/mnt/c/temp"
mkdir -p "$WIN_TEMP"
cp -f "$SCRIPT_DIR/usbip-attach.bat" "$WIN_TEMP/"

# Determine the name of this WSL distro on the system
WSL_DISTRO="$(IFS='\'; x=($(wslpath -w /)); echo "${x[${#x[@]}-1]}")"

# Run the helper batch file; wait until it produces a file called "COMPLETE" (cmd.exe returns almost immediately)
cd "$WIN_TEMP"
cmd.exe /c usbip-attach.bat $WSL_DISTRO $BUSID
while [ ! -f COMPLETE ]; do sleep 1; done

# Cleanup
rm -rf "$WIN_TEMP"
cd "$CURRENT_DIR"
