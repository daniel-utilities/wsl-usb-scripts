#!/usr/bin/env bash
# Requires WSL2
# ALSO need to install this on the Windows side: https://github.com/dorssel/usbipd-win/releases
# https://devblogs.microsoft.com/commandline/connecting-usb-devices-to-wsl/

# ********************************************
#        CONFIGURATION VARIABLES
# ********************************************

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
INSTALL_DIR="/usr/local/bin"

INSTALL_FILES="
$SCRIPT_DIR/usbip-attach.sh           : $INSTALL_DIR/usbip-attach
$SCRIPT_DIR/usbip-detach.sh           : $INSTALL_DIR/usbip-detach
$SCRIPT_DIR/usbip-list.sh             : $INSTALL_DIR/usbip-list
$SCRIPT_DIR/usbip-automount-daemon.sh : /usr/sbin/usbip-automount
$SCRIPT_DIR/usbip-automount-init.sh   : /etc/init.d/usbip-automount
$SCRIPT_DIR/usbip-automount-config    : /etc/default/usbip-automount
"


# ********************************************
#                FUNCTIONS
# ********************************************

# is_wsl2:  Checks if script is being run within WSL2.
# Inputs:
#   None
# Outputs:
#   echo true/false
#
is_wsl2() {
    grep -q "WSL2" /proc/version && echo true || echo false
}

# trim:  Trims leading and trailing whitespace from a string
# Inputs:
#   trim "\t string_with_whitespace \n  "
# Outputs:
#   echo string_without_whitespace
#
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

# auto_install:  Copies files from SOURCE to DESTINATION and applies chmod +x to scripts.
# Inputs:
#   auto_install "SOURCE_1 : DEST_1     Copies files, creating new folders if necessary.
#                 SOURCE_2 : DEST_2 "   Will use 'sudo' if necessary to gain write privilege.
# Outputs:
#   None
#
auto_install() {
    IFS=$'\n' declare -a 'ARR=($*)'
    for LINE in "${ARR[@]}"; do
        IFS=':' declare -a 'PAIR=($LINE)'
        local SRC=$(trim "${PAIR[0]}")
        local DST=$(trim "${PAIR[1]}")
        local DST_DIR=$(dirname "$DST")
        echo "$SRC --> $DST"
        mkdir -p "$DST_DIR" 2> /dev/null || sudo mkdir -p "$DST_DIR"
        cp -f "$SRC" "$DST" 2> /dev/null || sudo cp -f "$SRC" "$DST"
        if [[ "$SRC" == *.sh ]]; then 
            chmod +x "$DST" 2> /dev/null || sudo chmod +x "$DST"
        fi
    done
}
# printf "%s" "$IFS" | od -bc

# ********************************************
#                BEGIN
# ********************************************

# Assert WSL2
if [[ "$(is_wsl2)" == false ]]; then
    echo "This script must be run inside WSL2 only!"
    exit
fi


# Install USB-IP drivers in WSL2
sudo apt-get install -y linux-tools-virtual hwdata
sudo update-alternatives --install /usr/local/bin/usbip usbip `ls /usr/lib/linux-tools/*/usbip | tail -n1` 20   

# Install new files 
service usbip-automount stop
auto_install "$INSTALL_FILES"

# Give user permissions to start udev service
APPEND="$USER ALL=(ALL) NOPASSWD: /etc/init.d/udev"
FILE="/etc/sudoers"
echo "Adding line: \"$APPEND\" to $FILE..."
if [ -z "$(sudo grep "$APPEND" "$FILE" )" ]; then
    echo "$APPEND" | sudo EDITOR='tee -a' visudo
fi

# Give user permissions to start usbip-automount service
APPEND="$USER ALL=(ALL) NOPASSWD: /etc/init.d/usbip-automount"
FILE="/etc/sudoers"
echo "Adding line: \"$APPEND\" to $FILE..."
if [ -z "$(sudo grep "$APPEND" "$FILE" )" ]; then
    echo "$APPEND" | sudo EDITOR='tee -a' visudo
fi

# Start udev service with ~/.profile
APPEND="(nohup sudo /etc/init.d/udev start </dev/null >/dev/null 2>&1 &)"
FILE="$HOME/.profile"
echo "Adding line: \"$APPEND\" to $FILE..."
grep -qxF "$APPEND" "$FILE" || echo "$APPEND" | tee -a "$FILE" > /dev/null

# Start usbip-automount service with ~/.profile
APPEND="(nohup service usbip-automount start </dev/null >/dev/null 2>&1 &)"
FILE="$HOME/.profile"
echo "Adding line: \"$APPEND\" to $FILE..."
grep -qxF "$APPEND" "$FILE" || echo "$APPEND" | tee -a "$FILE" > /dev/null

# done
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
