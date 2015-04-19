#!/bin/bash

### BEGIN INIT INFO
# Provides:             youchoose
# Required-Start:       $all
# Required-Stop:        $all
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    youchoose
### END INIT INFO

DAEMON="NODE_ENV=production /var/www/youchoose/node_modules/coffee-script/bin/coffee /var/www/youchoose/app.coffee"
DAEMON_ARGS="36005"
DAEMON_NAME=youchoose
DAEMON_USER=youchoose
PID_FILE=/var/run/youchoose.pid
LOG_FILE=/var/log/youchoose/youchoose.log
WORKING_DIR=/var/www/youchoose
DESC="youchoose"

if [ `id -u` -ne 0 ]; then
    echo "You need root privileges to run this script"
    exit 1
fi

. /lib/lsb/init-functions

if [ -r /etc/default/rcS ]; then
    . /etc/default/rcS
fi

start() {
    log_daemon_msg "Starting $DESC"

    #pid=`pidofproc -p $PID_FILE`
    #if [ -n "$pid" ] ; then
    #    log_begin_msg "Already running"
    #    log_end_msg 0
    #    exit 0
    #fi

    nohup start-stop-daemon -c $DAEMON_USER -n $DAEMON_NAME -d $WORKING_DIR -p $PID_FILE -m --exec /usr/bin/env --start $DAEMON -- $DAEMON_ARGS >>$LOG_FILE 2>&1 &
    log_end_msg $?
}

stop() {
    log_daemon_msg "Stopping $DESC"

    if [ -f "$PID_FILE" ]; then
        start-stop-daemon --stop --pidfile "$PID_FILE" \
            --user "$DAEMON_USER" \
            --retry=TERM/20/KILL/5 >/dev/null
        if [ $? -eq 1 ]; then
            log_progress_msg "$DESC is not running but pid file exists, cleaning up"
        elif [ $? -eq 3 ]; then
            PID="`cat $PID_FILE`"
            log_failure_msg "Failed to stop $DESC (pid $PID)"
            exit 1
        fi
        rm -f "$PID_FILE"
    else
        log_progress_msg "(not running)"
    fi
    log_end_msg 0
}

status() {
    status_of_proc -p $PID_FILE $DAEMON $DESC && exit 0 || exit $?
}

restart() {
    if [ -f "$PID_FILE" ]; then
        $0 stop
        sleep 1
    fi
    $0 start
}

case "$1" in
    start | stop | status | restart)
        $1
        ;;
    *)
        echo "Usage: $0 {start|stop|status|restart}"
        exit 2
esac

exit $?