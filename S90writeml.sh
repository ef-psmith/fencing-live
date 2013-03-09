#!/bin/sh
# writexml      This shell script takes care of starting and stopping
#               writexml.pl

pidfile="/share/Public/writexml.pid"

# See how we were called.
case "$1" in
  start)
	# Stop daemons
	[ -f $pidfile ] && /bin/kill -HUP `cat $pidfile`
	
	# Start daemons
	
	echo -n "Starting writexml: "

	cd /share/Public/engarde/live
	perl writexml.pl &
	echo $! > $pidfile

	echo -n "writexml"
	echo "."
	
	
	;;
  stop)
	# Stop daemons.
	echo -n "Shutting down writexml: "
	[ -f $pidfile ] && /bin/kill -HUP `cat $pidfile`
	echo -n "writexml"
	echo "."
	;;
  restart)
	$0 start
	RETVAL=$?
	;;
  *)
	echo "Usage: $0 { [start]|stop|[restart] }"
	exit 1
esac

exit 0
