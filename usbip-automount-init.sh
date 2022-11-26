#!/usr/bin/env bash
### BEGIN INIT INFO
# Provides:          usbip-automount         
# Required-Start:    $local_fs $network $named $time $syslog 
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Autoattaches specified host USB devices
# Description:       Periodically polls host's USB devices and attaches those matched by the config file.
### END INIT INFO

NAME="usbip-automount"
CONFIG="/etc/default/$NAME"
DAEMON="/etc/init.d/$NAME"
COMMAND="$DAEMON $CONFIG"
# COMMAND='(echo "$PATH"; sleep 10; echo done)'
PATH="/usr/local/bin:$PATH"
PIDFILE=/var/run/$NAME.pid
LOGFILE=/var/log/$NAME.log


is_root() {
    [ "$EUID" -eq 0 ] && return 0 || return 1
}

is_running() {
    if [ -f "$PIDFILE" ] && ps -p $(cat "$PIDFILE") > /dev/null; then
        return 0
    else
        return 1
    fi
}

# start
# Return:
#   0 if daemon has been started
#   1 if daemon was already running
#   2 if daemon could not be started
start() {
    if is_running; then
      echo "Service already running."
      return 1
    fi
    if ! is_root; then
        echo "Error: root required to start or stop this service."
        return 2;
    fi

    echo "Starting service $NAME..."
    mkdir -p "$(dirname "$PIDFILE")" 2>/dev/null
    mkdir -p "$(dirname "$LOGFILE")" 2>/dev/null
    bash -c "$COMMAND"  \
        </dev/null      \
        2>&1            \
        1>"$LOGFILE"    \
    & echo $!           \
    | tee "$PIDFILE" > /dev/null

    if [ $? -eq 0 ]; then
        echo "Service started."
        return 0
    else
        echo "Error: Failed to start service."
        return 2
    fi
}

# stop
# Return:
#   0 if daemon has been stopped
#   1 if daemon was already stopped
#   2 if daemon could not be stopped
#   other if a failure occurred
stop() {
    if ! is_running; then
        echo "Service not running."
        rm -f "$PIDFILE"
        return 1;
    fi
    if ! is_root; then
        echo "Error: root required to start or stop this service."
        return 2;
    fi

    echo "Stopping $NAME service..."
    kill -15 $(cat "$PIDFILE") && rm -f "$PIDFILE"

    if [ $? -eq 0 ]; then
        echo "Service stopped."
        return 0
    else
        echo "Error: Failed to stop service."
        return 2
    fi
}

status() {
    if is_running; then
      echo "Service $NAME is running."
      return 0
    else
      echo "Service $NAME is not running."
      return 2
    fi
}


case "$1" in 
    start)
       start
       ;;
    stop)
       stop
       ;;
    restart|force-reload)
       stop && start
       ;;
    status)
       status
       ;;
    *)
       echo "Usage: $0 {start|stop|status|restart}"
esac

exit $? 
