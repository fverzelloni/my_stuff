#!/bin/bash

# VAR

# ROUTINE

case "$1" in

"-q" )
	cat /tmp/test1 | column -t
	;;

"-w" )
	cat /tmp/test1 | awk '{ if ( $6 - $11 <= 2 ) print "WARNING" " "$3 " reached the limits of licences available " ; else print "Licences status OK"  }'
	;;

"-n" )
        cat /tmp/test1 | awk '{ if ( $6 - $11 <= 2 ) print "WARNING" " "$3 " reached the limits of licences available " }' | grep WARNING
        exit 1
        ;;

"-h" )
	echo "usage: ${0##*/} -q  Query available license"
        echo "usage: ${0##*/} -w  Warning if licence limits is reached"
	echo "Usage: ${0##*/} -n  Nagios check"
        echo "usage: ${0##*/} -h  Print this message"
        exit 1
        ;;

* )
	echo "usage: ${0##*/} -q  Query available license"
	echo "usage: ${0##*/} -w  Warning if licence limits is reached"
	echo "Usage: ${0##*/} -n  Nagios check"
	echo "usage: ${0##*/} -h  Print this message"
	exit 1
	;;

esac
exit 0
