#!/usr/bin/env bash
CURRENT_DIR=$PWD

if [[ $# == 1 ]]; then
    BUSID=$1
else
    echo "USAGE:  usb-attach BUSID"
    exit
fi

# Find where this script is located
SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE
done
INSTALL_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )


# Copy the helper batch file to a temporary directory in Windows
WIN_TEMP="$(wslpath 'C:\temp')"
mkdir -p "$WIN_TEMP"
cp -f "$INSTALL_DIR/usbip-attach.bat" "$WIN_TEMP/"

# Determine the name of this WSL distro on the system
WSL_DISTRO="$(IFS='\'; x=($(wslpath -w /)); echo "${x[${#x[@]}-1]}")"

# If cmd.exe not on PATH, go find it
CMD="cmd.exe"
[[ ! $(type -P "cmd.exe") ]] && CMD="$(wslpath 'C:\Windows\System32\cmd.exe')"

# Run the helper batch file; wait until it produces a file called "COMPLETE"
cd "$WIN_TEMP"
"$CMD" /c usbip-attach.bat $WSL_DISTRO $BUSID
while [ ! -f "COMPLETE" ]; do sleep 1; done

# Cleanup
rm -rf "$WIN_TEMP"
cd "$CURRENT_DIR"
