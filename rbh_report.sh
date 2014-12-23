#!/bin/bash 


########################
#
# rbhreport remote query
#
#######################


# ROUTINE

function msg() { echo -e >&2 "$@"; }

case "$1" in

	"-i" )
		RBH_INFO=$(ssh user@server "/usr/sbin/rbh-report -f /etc/robinhood.d/tmpfs/rbh_query.conf -i 2>/dev/null ")
                echo -e "$RBH_INFO"
                ;;

	"-tu" )
		RBH_TOPUSERS=$(ssh user@server "/usr/sbin/rbh-report -f /etc/robinhood.d/tmpfs/rbh_query.conf --top-users 2>/dev/null | tail -n+1 |sed 's/,//'g")
		echo -e "$RBH_TOPUSERS"
		;;
	
	"-g" )
		RBH_GROUP=$(ssh user@server "/usr/sbin/rbh-report -f /etc/robinhood.d/tmpfs/rbh_query.conf -g $2 2>/dev/null ")
		echo -e "$RBH_GROUP "
		;;

	"-u" )
		RBH_USER=$(ssh user@server "/usr/sbin/rbh-report -f /etc/robinhood.d/tmpfs/rbh_query.conf -u $2 2>/dev/null | sed 's/,//'g")
		echo -e "$RBH_USER"
		;;
	
	* )		
			msg "usage: ${0##*/} -i {Display statistics about filesystem contents.}"
			msg "usage: ${0##*/} -tu {Display top disk space consumers. Optional argument indicates the number of users to be returned (default: 20).} "
			msg "usage: ${0##*/} -g {Display group statistics. Use optional parameter groupname for retrieving stats about a single group.} "
                        msg "usage: ${0##*/} -u {Display user statistics. Use optional parameter username for retrieving stats about a single user.} "
		;;
		

esac
exit 0
