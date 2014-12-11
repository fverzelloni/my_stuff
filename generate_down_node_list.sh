#!/bin/bash -l

pathtowith=5

function msg() { echo -e >&2 "$@"; }

case "$1" in 

	"-f" | "--file" )
			if [ "$2" != "" ]
			then
			xtprocadmin |grep down | tr "," "\n" | awk '{ print $1" "$5" "$3 }' > list1
			cat list1 | awk '{ print $1 }' | while read line ; do printf "nid%0*d\n" $pathtowith $line ; done > list3
			paste list3 list1 | column -s $'\t' -t | awk '{ print $1","" "","" "","" "","" "","" ""," $3" "","$4 }' > $2
			rm list1 list3
			else
			echo "usage: ${0##*/} -f|--file FILENAME {to create a file} "
                        echo "usage: ${0##*/} -o|--output {to print in stdout}"
                        exit 1
			fi
			;;

	"-o" | "--output" )
			xtprocadmin |grep down | tr "," "\n" | awk '{ print $1" "$5" "$3 }' > list1
			cat list1 | awk '{ print $1 }' | while read line ; do printf "nid%0*d\n" $pathtowith $line ; done > list3
			paste list3 list1 | column -s $'\t' -t | awk '{ print $1","" "","" "","" "","" "","" ""," $3" "","$4 }' 
			rm list1 list3
			;;

	"-c" | "--count" )
                        xtprocadmin |grep down | tr "," "\n" | awk '{ print $1" "$5" "$3 }' > list1
                        cat list1 | awk '{ print $1 }' | while read line ; do printf "nid%0*d\n" $pathtowith $line ; done > list3
                        paste list3 list1 | column -s $'\t' -t | awk '{ print $1","" "","" "","" "","" "","" ""," $3" "","$4 }' | wc -l
                        rm list1 list3
                        ;;

	"-h" | "--help" )
			msg "usage: ${0##*/} -c|--count {to count down/admindown nodes} "
			msg "usage: ${0##*/} -f|--file FILENAME {to create a file} "
			msg "usage: ${0##*/} -o|--output {to print in stdout}"
                        exit 1
                        ;;

	* )		
			msg "usage: ${0##*/} -c|--count FILENAME {to count down/admindown nodes}"
			msg "usage: ${0##*/} -f|--file FILENAME {to create a file}"
			msg "usage: ${0##*/} -o|--output {to print in stdout}"
			exit 1
			;;


esac
exit 0
