#!/bin/bash -l

RPCS=64
DIRTY=256
PATHTOWIDTH=5
#LIST=$(xtprocadmin | grep comp | awk '{ print $1 }' | while read line ;  do  printf "nid%0*d\n" $PATHTOWIDTH $line ; done)
LIST=$(xtprocadmin | grep compute | awk '{ print $3 }' | tr "\n" ",")
UPNODES_LIST=$( $XTPROCADMIN | grep compute | grep up | awk '{ print $3 }' | tr "\n" "," )

# ROUTINE


function msg() { echo -e >&2 "$@"; }

case "$1" in

	"-d" )
		if [ "$2" != "" ]
                        then
				OST=$(pdsh -w $LIST ls /proc/fs/lustre/osc/ | grep $2 | sed 's/://g')
				echo -e "$OST" | while  read -r f1 f2 ; do echo "ssh -n $f1 \" echo $DIRTY > /proc/fs/lustre/osc/$f2/max_dirty_mb \" "; done
				echo -e "$OST" | while  read -r f1 f2 ; do echo "ssh -n $f1 \" echo $RPCS  > /proc/fs/lustre/osc/$f2/max_rpcs_in_flight \" "; done
			else
                                ${0##*/} -h
                        exit 1
                        fi
		;;
	
	"-g" )
		if [ "$2" !=  "" ]
                        then
				pdsh -w $LIST cat /proc/fs/lustre/osc/$2*/max_dirty_mb | sed 's/:/ max_dirty_mb=/g'
				pdsh -w $LIST cat /proc/fs/lustre/osc/$2*/max_rpcs_in_flight | sed 's/:/ max_rpcs_in_flight=/g'
			else
				${0##*/} -h
                                exit 1
                        fi
		;;

	"-q" )
                if [ "$2" !=  "" ]
                        then
                                pdsh -w $LIST ls /proc/fs/lustre/osc/ | grep $2 | sed 's/://g'
                        else
                                ${0##*/} -h
                                exit 1
                        fi
                ;;

	"-w" )
		if [ "$2" != "" ]
                        then
				OST=$(pdsh -w $LIST ls /proc/fs/lustre/osc/ | grep $2 | sed 's/://g')
				echo -e "$OST" | while  read -r f1 f2 ; do ssh -n $f1 " echo $DIRTY > /proc/fs/lustre/osc/$f2/max_dirty_mb" ; done
				echo -e "$OST" | while  read -r f1 f2 ; do ssh -n $f1 " echo $RPCS  > /proc/fs/lustre/osc/$f2/max_rpcs_in_flight" ; done
			else
                                ${0##*/} -h
                        exit 1
                        fi
		;;

	"-h" | "--help" )
		${0##*/}
                exit 1
                ;;

	* )
		msg "usage: ${0##*/} -q \"snx\" {Display OSTs target for the specified lustre fs}"
		msg "usage: ${0##*/} -d \"snx\" {Dry run mode}"
		msg "usage: ${0##*/} -g \"snx\" {Get the parameters currently in place}"
		msg "usage: ${0##*/} -w \"snx\" {Apply the desire parameters,specified in the script variable RPCS / DIRTY}"
		msg "usage: ${0##*/} -h "
		exit 1
		;;

esac
exit 0
