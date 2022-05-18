#!/usr/bin/env bash

if [[ $# == 1 ]]; then
    BUSID=$1
else
    echo "USAGE:  usbip-detach BUSID"
    exit
fi

cmd.exe /c usbipd wsl detach --busid $1

