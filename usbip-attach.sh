#!/usr/bin/env bash

# ********************************************
#                USAGE
# ********************************************
if [[ $# == 1 ]]; then
    BUSID=$1
else
    echo "USAGE:  usbip-attach BUSID"
    exit
fi

# ********************************************
#        CONFIGURATION VARIABLES
# ********************************************

# Determine the name of this WSL distro on the system
DISTRO="$(IFS='\'; x=($(wslpath -w /)); echo "${x[${#x[@]}-1]}")"

# If powershell.exe not on PATH, go find it
POWERSHELL="powershell.exe"
[[ ! $(type -P "$POWERSHELL") ]] && POWERSHELL="$(wslpath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe')"

# usbipd
EXE="usbipd"
ARGS="wsl attach -d $DISTRO -b $BUSID -a"
HIDE_WINDOW=true
ELEVATED=false


# ********************************************
#                FUNCTIONS
# ********************************************

# win_exec: start a Windows process in a new Powershell window, from within WSL.
# Inputs:
#   $POWERSHELL  - WSL path to powershell.exe (or cmd /c powershell.exe)
#   $EXE         - Windows path to executable file
#   $ARGS        - Arguments to pass to EXE
#   $HIDE_WINDOW - (true/false). Powershell window will be hidden.
#   $ELEVATED    - (true/false). EXE will be launched as Administrator.
#                    UAC will be invoked if enabled on the system.
# Outputs:
#   $EXITCODE    - Numeric exit value of the process. 0 indicates success.
#
win_exec() {
    local FIXEDARGS=${ARGS//\'/\'\'}
    local PARAMS="\"$EXE\" -ArgumentList '$FIXEDARGS' -Wait -PassThru"
    if [[ "$HIDE_WINDOW" == true ]]; then PARAMS="$PARAMS -WindowStyle Hidden"; fi
    if [[ "$ELEVATED" == true ]]; then PARAMS="$PARAMS -Verb RunAs"; fi
    local CMD="\$PROC=Start-Process $PARAMS; \$PROC.hasExited | Out-Null; \$PROC.GetType().GetField('exitCode', 'NonPublic, Instance').GetValue(\$PROC); exit"
    EXITCODE=$("$POWERSHELL" -NoProfile -ExecutionPolicy Bypass -Command "$CMD" | tr -d '[:space:]')
}


# ********************************************
#                BEGIN
# ********************************************

# Execute usbipd with default settings
win_exec

if [[ "$EXITCODE" == "3" ]]; then
    echo "Device $BUSID has not yet been bound to USBIPD service, and requires Administrator privilege."
    echo "Retrying with elevation..."
    ELEVATED=true
    win_exec
fi    

if [[ "$EXITCODE" == "0" ]]; then
    echo "Success"
elif [[ "$EXITCODE" == "1" ]]; then
    echo "Device $BUSID is already attached."
else
    echo "USBIP returned error code $EXITCODE."
    echo "From Windows, run the following command for more info:"
    echo "$EXE $ARGS"
fi

exit $EXITCODE
