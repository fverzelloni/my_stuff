#!/bin/bash -l

#############################################################################################
#  Generate down/admindown nodes list
#
#  Version 1.0 FV/12 December 2014
#############################################################################################


## VARs

PATHTOWITH=5
FILE_PATH=/tmp/nodes_down
HOSTNAME="$(hostname | sed 's/[0-9]//g')"
DATE="$(date +%d%m%y_%H%M)"
CLOG=$(ls -tr1 $FILE_PATH/*.log 2>/dev/null | tail -n1)
OLOG=$(ls -tr1 $FILE_PATH/*.log 2>/dev/null | tail -n2 | head -n1)

## ROUTINE

if [ ! -d $FILE_PATH ]
	then 
		mkdir $FILE_PATH
fi

function msg() { echo -e >&2 "$@"; }

case "$1" in 
	
	"-a" | "-auto" )
			${0##*/} -o > $FILE_PATH/nodes_down_$DATE.log
			;;
	
	"-c" | "--count" )
                        ${0##*/} -o | wc -l
                        ;;

        "-C" | "--compare" )
			if [ ! -z $CLOG ] && [ ! -z $OLOG ] && [ "$CLOG" != "$OLOG" ]
				then 
					DIFF=$(diff -a --suppress-common-lines -y $OLOG $CLOG)
                        		if [ -n "$DIFF" ]
                                		then
                                        		echo "$DIFF" | sed 's/,/ /g'
                        		fi
			fi
                        ;;
	
	"--csv" )
                        if [ "$2" != "" ]
                        then
                                xtprocadmin |grep down | tr "," "\n" | awk '{ print $1" "$5" "$3 }' > $FILE_PATH/list1
                                cat $FILE_PATH/list1 | awk '{ print $1 }' | while read line ; do printf "nid%0*d\n" $PATHTOWITH $line ; done > $FILE_PATH/list2
                                paste $FILE_PATH/list2 $FILE_PATH/list1 | column -s $'\t' -t | awk '{ print  $1","" "","" "","" "","" "","" ""," $3" "","$4 }' > $2
                                rm $FILE_PATH/list1 $FILE_PATH/list2
                        else
                                ${0##*/} -h
                        exit 1
                        fi
                        ;;

	"-e" | "--email" )
                        if [ "$2" != "" ]
                        then
                                ${0##*/} -o | mail -s "Nodes down list $HOSTNAME" $2
                        else
                                ${0##*/} -h
                        exit 1
                        fi
                        ;;

	"-f" | "--file" )
			if [ "$2" != "" ]
			then
				${0##*/} -o > $2
			else
				${0##*/} -h
                        exit 1
			fi
			;;

	"-o" | "--output" )
			xtprocadmin |grep down | tr "," "\n" | awk '{ print $1" "$5" "$3 }' > $FILE_PATH/list1
                        cat $FILE_PATH/list1 | awk '{ print $1 }' | while read line ; do printf "nid%0*d\n" $PATHTOWITH $line ; done > $FILE_PATH/list2
                        paste $FILE_PATH/list2 $FILE_PATH/list1 | column -s $'\t' -t | awk '{ printf ("%-11s%-12s%-s\n" ,$1, $3, $4) }'
                        rm $FILE_PATH/list1 $FILE_PATH/list2
                        ;;

	"-h" | "--help" )
			${0##*/}
                        exit 1
                        ;;

	* )		
			msg "usage: ${0##*/} -c|--count {to count down/admindown nodes} "
                        msg "usage: ${0##*/} --csv FILENAME {to genereate an output file in CSV format} "
                        msg "usage: ${0##*/} -e|--email email@address {to send an email with the attached down nodes list} "
                        msg "usage: ${0##*/} -f|--file FILENAME {to create a file} "
                        msg "usage: ${0##*/} -o|--output {to print in stdout}"
                        exit 1
			;;

esac
exit 0
