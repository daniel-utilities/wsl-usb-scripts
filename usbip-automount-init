#!/usr/bin/env /lib/init/init-d-script
### BEGIN INIT INFO
# Provides:          usbip-automount         
# Required-Start:    $syslog $time $remote_fs
# Required-Stop:     $syslog $time $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Autoattaches specified host USB devices
# Description:       Periodically polls host's USB devices and attaches those matched by the config file.
### END INIT INFO
NAME="usbip-automount"
DESC="$NAME"
DAEMON="/bin/bash"
BASH_COMMAND="/usr/sbin/$NAME >/dev/null 2>&1 < /dev/null &"
PATH="/usr/local/bin:$PATH"

do_start_cmd_override() {
  echo
  start-stop-daemon --start --quiet --pidfile $PIDFILE \
      $START_ARGS --startas $DAEMON --name $NAME --exec $DAEMON -- -l -c "$BASH_COMMAND" \
      || return 2
}

do_stop_cmd_override() {
    pkill -f "$NAME"

    iterator=0
    while [ $iterator -lt 5 ]; do
        if ! status_cmd; then break; fi
        sleep 1
    done
}

# Returns 0 (success) if process is still running, 1 if stopped
status_cmd() {
    COUNT="$(pgrep --count -f "$NAME")"
    [ 1 -eq "$(echo "${COUNT} > 1" | bc)" ]
}

do_restart_override() {
    status_cmd && call do_stop
    status_cmd || call do_start
}

do_status_override() {
  if status_cmd; then
    log_success_msg running
    exit 0
  else
    log_failure_msg not running
    exit 2
  fi
}

do_start_prepare() {
  status_cmd && exit 0
}

do_stop_prepare() {
  status_cmd || exit 0
}

do_start_override() {
  if ! status_cmd; then
    [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
    call do_start_cmd
    case "$?" in
            0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
            2) [ "$VERBOSE" != no ] && log_end_msg 1; exit 2 ;;
    esac
  else
    [ "$VERBOSE" != no ] && log_daemon_msg "Service $NAME is already running" && log_end_msg 1 && exit 2
  fi
}

do_status_override() {
  if status_cmd; then
    log_success_msg running
    exit 0
  else
    log_failure_msg not running
    exit 2
  fi
}
