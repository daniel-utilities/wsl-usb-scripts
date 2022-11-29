

# Prereqs
function install_prerequisites() {
    local -a packages=(
        linux-tools-virtual
        hwdata
        lsb-release
    )

    echo ""
    echo "The following APT packages will be installed:" 
    echo "${packages[@]}"
    echo ""
    if ! confirmation_prompt; then return; fi;
    echo ""

    sudo apt-get update
    sudo apt-get install -y ${packages[@]}
    sudo update-alternatives --install /usr/local/bin/usbip usbip `ls /usr/lib/linux-tools/*/usbip | tail -n1` 20   
}

# Download and run convenience script
function install_files() {
    local script_dir
    get_script_dir script_dir
    local -a install_files=(
        "$script_dir/usbip-attach.sh           : /usr/local/bin/usbip-attach"
        "$script_dir/usbip-detach.sh           : /usr/local/bin/usbip-detach"
        "$script_dir/usbip-list.sh             : /usr/local/bin/usbip-list"
        "$script_dir/usbip-automount-daemon.sh : /usr/sbin/usbip-automount"
        "$script_dir/usbip-automount-init.sh   : /etc/init.d/usbip-automount"
    )
    # Don't overwrite previous config file
    if [ ! -e "/etc/default/usbip-automount" ]; then
        install_files+=( "$script_dir/usbip-automount-config : /etc/default/usbip-automount" )
    fi

    echo ""
    echo "The following files will be installed:" 
    print_arr install_files
    echo ""
    if ! confirmation_prompt; then return; fi;
    echo ""

    multicopy install_files
}

# Set services to run automatically
function enable_services() {
    if is_systemd; then
        local -a services=(
            udev
            usbip-automount
        )
        local fncall='sysd_config_system_service'
    else
        local -a services=(
            udev
            usbip-automount
        )
        local fncall='sysv_config_user_service'
    fi

    echo ""
    echo "The following services will be started automatically on boot:" 
    print_arr services
    echo ""
    if ! confirmation_prompt; then return; fi;
    echo ""

    for service in "${services[@]}"; do
        $fncall $service enable start
    done

    sudo udevadm control --reload-rules
    sudo udevadm trigger
}
