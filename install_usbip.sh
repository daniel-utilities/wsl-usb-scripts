#!/usr/bin/env bash
# Requires WSL2
# ALSO install this on the Windows side: https://github.com/dorssel/usbipd-win/releases
# https://devblogs.microsoft.com/commandline/connecting-usb-devices-to-wsl/
CURRENT_DIR=$PWD
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
WSL=$(if grep -q microsoft /proc/version; then echo 'true'; else echo 'false'; fi)
INSTALL_PATH="/usr/local/bin/wsl-usb-scripts"

if [ $WSL == 'false' ]; then
    echo "This script must be run inside WSL2 only!"
    exit
fi

# Install USB-IP drivers in WSL2
sudo apt-get install -y linux-tools-virtual hwdata
sudo update-alternatives --install /usr/local/bin/usbip usbip /usr/lib/linux-tools/*/usbip 20   

# Copy scripts to INSTALL_PATH
cd "$SCRIPT_DIR"
sudo mkdir -p "$INSTALL_PATH"
sudo cp -f ./* "$INSTALL_PATH/"

# Create symlinks to executables in /usr/local/bin so they are picked up by PATH
cd "$INSTALL_PATH"
sudo chmod +x *.sh
sudo ln -f -s "$INSTALL_PATH/usbip-attach.sh" "/usr/local/bin/usbip-attach"
sudo ln -f -s "$INSTALL_PATH/usbip-detach.sh" "/usr/local/bin/usbip-detach"
sudo ln -f -s "$INSTALL_PATH/usbip-list.sh" "/usr/local/bin/usbip-list"

# Install usbip-autoattach as init.d service so it runs automatically
sudo ln -f -s "$INSTALL_PATH/usbip-autoattach-service.sh" "/etc/init.d/usbip-autoattach"
sudo ln -f -s "$INSTALL_PATH/usbip-autoattach-daemon.sh" "/usr/sbin/usbip-autoattach"

# done
echo " "
echo "Make sure you have downloaded and installed the latest version of USB-IP on Windows:"
echo " https://github.com/dorssel/usbipd-win/releases "
echo " "

cd "$CURRENT_DIR"
