#!/bin/bash -l

FILE=/tmp/osc
RPCS=64
DIRTY=256
PATHTOWIDTH=5
LIST=$(xtprocadmin | grep comp | awk '{ print $1 }' | while read line ;  do  printf "nid%0*d\n" $PATHTOWIDTH $line ; done)

# Get the OST path
# xtprocadmin | grep comp | awk '{ print $1 }' 
# pdsh -w nid000[32-43] ls /proc/fs/lustre/osc/ | grep snx | sed 's/://g'
# pdsh -w nid000[32-43] ls /proc/fs/lustre/osc/ | grep sant | sed 's/://g'

### DRY RUN
#cat /tmp/osc | while  read -r f1 f2 ; do echo " ssh $f1 \"echo $DIRTY > /proc/fs/lustre/osc/$f2/max_dirty_mb\" "; done 
#cat /tmp/osc | while  read -r f1 f2 ; do echo " ssh $f1 \"echo $RPCS  > /proc/fs/lustre/osc/$f2/max_rpcs_in_flight\" "; done

### GET STATUS
#cat /tmp/osc | while  read -r f1 f2 ; do echo " ssh $f1 \" cat /proc/fs/lustre/osc/$f2/max_dirty_mb\" "; done
#cat /tmp/osc | while  read -r f1 f2 ; do echo " ssh $f1 \" cat /proc/fs/lustre/osc/$f2/max_rpcs_in_flight\" "; done

## RUN
#cat /tmp/osc | while  read -r f1 f2 ; do ssh $f1 "echo $DIRTY > /proc/fs/lustre/osc/$f2/max_dirty_mb"; done
#cat /tmp/osc | while  read -r f1 f2 ; do ssh $f1 "echo $RPCS  > /proc/fs/lustre/osc/$f2/max_rpcs_in_flight"; done

#echo -e "$OST"
# ROUTINE


function msg() { echo -e >&2 "$@"; }

case "$1" in

	"-l" )
		if [ "$2" != "" ]
			then
				OST=`echo -e "$LIST" | while read line ; do pdsh -w $line ls /proc/fs/lustre/osc/ | grep $2 | sed 's/://g' ; done`
				echo -e "$OST"
			else
				${0##*/} -h
                        exit 1
			fi
		;;

	"-d" )
		if [ "$2" != "" ]
                        then
				OST=`echo -e "$LIST" | while read line ; do pdsh -w $line ls /proc/fs/lustre/osc/ | grep $2 | sed 's/://g' ; done`
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
				OST=$(echo -e "$LIST" | while read line ; do pdsh -w $line ls /proc/fs/lustre/osc/ | grep $2 | sed 's/://g' ; done)
                                echo -e "$OST" | while  read -r f1 f2 ; do  ssh -n $f1 " cat /proc/fs/lustre/osc/$f2/max_dirty_mb " ; done | while read -r x1 ; do echo "$f1 max_dirty_mb: $x1" ; done
                                echo -e "$OST" | while  read -r f1 f2 ; do  ssh -n $f1 " cat /proc/fs/lustre/osc/$f2/max_rpcs_in_flight " ; done | while read -r x1 ; do echo "$f1 max_rpcs_in_flight: $x1" ; done
			else
				${0##*/} -h
                                exit 1
                        fi
		;;

	"-w" )
		if [ "$2" != "" ]
                        then
				echo -e "$OST" | while  read -r f1 f2 ; do ssh $f1 " echo $DIRTY > /proc/fs/lustre/osc/$f2/max_dirty_mb" ; done
				echo -e "$OST" | while  read -r f1 f2 ; do ssh $f1 " echo $RPCS  > /proc/fs/lustre/osc/$f2/max_rpcs_in_flight" ; done
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
		msg "usage: ${0##*/} -l \"snx\" {Display OSTs target for the specified lustre fs}"
		msg "usage: ${0##*/} -d \"snx\" {Dry run mode}"
		msg "usage: ${0##*/} -g \"snx\" {Get the parameters currently in place}"
		msg "usage: ${0##*/} -w \"snx\" {Apply the desire parameters,specified in the script variable RPCS / DIRTY}"
		msg "usage: ${0##*/} -h "
		exit 1
		;;

esac
exit 0
