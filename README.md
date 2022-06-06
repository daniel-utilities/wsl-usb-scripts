# wsl-usb-scripts
### Scripts for managing USB passthrough with WSL2
 
## Prerequisites
This software requires the following to be installed:
- WSL2 (Only available on Windows 11 and recent Windows 10 builds)
- Ubuntu for WSL2 (Other distros not tested)
- [USB-IP services for Windows](https://github.com/dorssel/usbipd-win/releases)
- Administrator rights on Windows (required to mount USB devices using usbipd)

## Installation
In a new Ubuntu terminal, run:
```
git clone https://github.com/daniel-scripts/wsl-usb-scripts.git
chmod +x ./install.sh
./install.sh
```
This performs the following:
1. Installs USB-IP support in Linux
2. Installs scripts to /usr/local/bin
3. Installs an init.d service (``usbip-automount``) which automatically attaches USB devices specified by the config file. See next section for details.

## Scripts
After installation, the following can be run at the Ubuntu terminal:
- ``usbip-list``: Lists the USB devices on the Windows host
- ``usbip-attach {BUS_ID}``: Attaches the device at the specified port (BUS_ID) to this WSL instance. Properly handles multiple WSL installations.
- ``usbip-detach {BUS_ID}``: Detaches the device from WSL, returning it to the host.
- ``service usbip-automount {start|stop|restart|status}``: Manages the usbip-automount service.

## Configuring usbip-automount
The ``usbip-automount`` service reads the configuration file at /etc/default/usbip-automount. See file for details.

The service periodically scans the host for unattached USB devices (by running ``usbip-list``) and attaches devices matching the criteria in /etc/default/usbip-automount.

You can match devices based on name, USB port (BUS_ID), or Vendor/Product ID.

From the configuration file:
```
Each line is a substring of a device descriptor returned by usb-list
EXAMPLE:
$ usbip-list
BUSID  VID:PID    DEVICE                                                        STATE
1-4    27c6:55a2  Goodix fingerprint                                            Not attached
1-5    1234:0123  USB Mass Storage Device                                       Not attached
1-6    13d3:5419  Integrated Camera, Integrated IR Camera, Camera DFU Device    Not attached
1-14   0694:0002  Lego Mindstorms NXT                                           Not attached

To autoattach all cameras, use:
export DEVICE_MATCH_SUBSTRINGS="
Camera
"

To autoattach whatever is on port 1-5, use:
export DEVICE_MATCH_SUBSTRINGS="
1-5
"

To autoattach all Mindstorms NXT microcontrollers regardless of what port they are connected, use:
export DEVICE_MATCH_SUBSTRINGS="
0694:0002
"
```

After editing /etc/default/usbip-automount, run ``service usbip-automount restart`` to reload the configuration.


