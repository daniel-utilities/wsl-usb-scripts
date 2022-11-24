#!/usr/bin/env bash

# Requires WSL2
# ALSO need to install this on the Windows side: https://github.com/dorssel/usbipd-win/releases
# https://devblogs.microsoft.com/commandline/connecting-usb-devices-to-wsl/

# ***************************************
# FUNCTIONS
# ***************************************
script_dir="$(dirname "$(readlink -f "$0")")"

# Import functions from other files
sources=(   "$script_dir/bash-common-scripts/common-functions.sh" 
            "$script_dir/bash-common-scripts/wsl-functions.sh"
            "$script_dir/installation-routines.sh"                     )
for i in "${sources[@]}"; do
    if [ ! -e "$i" ]; then
        echo "Error - could not find required source: $i"
        echo "Please run:"
        echo "  git submodule update --init --recursive --remote"
        echo ""
        exit 1
    else
        source "$i"
    fi
done


# ***************************************
# SCRIPT START
# ***************************************
require_non_root
require_wsl2

# Main Menu
title="USBIP Installation Procedure"
description="""\
The following steps are required.
Please run them in order. \
"""
unset options
unset fncalls
declare -A options
declare -A fncalls; 
options[1]="Install prerequisites"
fncalls[1]="install_prerequisites"
options[2]="Install Files"
fncalls[2]="install_files"
options[3]="Enable Services"
fncalls[3]="enable_services"

function_select_menu options fncalls "$title" "$description"

echo "
The following scripts have been installed in \"$INSTALL_DIR\":
  usbip-list
  usbip-attach
  usbip-detach

Make sure you have downloaded and installed the latest version of USB-IP on Windows:
  https://github.com/dorssel/usbipd-win/releases

Please edit the config file to choose what devices to auto-attach to WSL:
  sudo nano /etc/default/usbip-automount

Then, restart your machine. Both 'udev' and 'usbip-automount' services should now start automatically.
"
