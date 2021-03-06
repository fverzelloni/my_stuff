#!/bin/bash -l

#VARs
REPORT_EX=$(rbh-report --top-users 2>/dev/null | grep -i TB | awk '{ print $2 " "$5" " $4}' | tail -n+1 |sed 's/,//'g | cut -f1 -d".")
RECIPIENT="email@email.ch"

#ROUTINE
if [ -f /tmp/warning_list.txt ] 
	then
		rm -f /tmp/warning_list.txt
fi

function msg() { echo -e >&2 "$@"; }

case "$1" in

	"-c" )
		if [ `hostname` != "daintrbh*" ] 
		then
                	echo -e "$REPORT_EX" | while read line
                		do
                       	 	if  [ $(echo $line | awk '{ print $3 }') -gt 100 ]
                                	then
                                        	echo "$line" >> /tmp/warning_list.txt
                                fi
                        	done
		fi

                if [ -f /tmp/warning_list.txt ]
                        then
                                cat "/tmp/warning_list.txt" | mail -s "[/scratch/daint] Warning: users in the attached list are using more then 100Tb of disk space" -a /tmp/warning_list.txt $RECIPIENT
                                rm /tmp/warning_list.txt
                fi
                ;;

	"-o" )
		if [ `hostname` != "daintrbh*" ]
                	then
				${0##*/} -h
                                exit 1
			else	
				echo -e "$REPORT_EX" | while read line
					do
						if  [ $(echo $line | awk '{ print $3 }') -gt 100 ]
        						then
                						echo "$line"
						fi
					done
		fi
		;;

	"-e" )
		if [ `hostname` != "daintrbh*" ]
			then
                                ${0##*/} -h
                                exit 1
                        else
				if [ "$2" != "" ]
                        		then
						echo -e "$REPORT_EX" | while read line  
							do
								if  [ $(echo $line | awk '{ print $3 }') -gt 100 ]
									then
										echo "$line" >> /tmp/warning_list.txt
								fi
							done
					else
						${0##*/} -h
                        			exit 1
				fi
		fi
		
		if [ -f /tmp/warning_list.txt ]
        		then
                		cat "/tmp/warning_list.txt" | mail -s "[/scratch/daint] Warning: users in the attached list are using more then 100Tb of disk space" -a /tmp/warning_list.txt $2
				rm /tmp/warning_list.txt
		fi
		;;
	"-r" )
		REPORT_REMOTE=$( ssh root@remote_host "rbh-report --top-users 2>/dev/null | grep -i TB | awk '{ print $2 " "$5" " $4}'  | tail -n+1 |sed 's/,//'g | cut -f1 -d"."" )
		if [ `hostname` != "daintrbh*" ]
			then
				echo -en "$REPORT_REMOTE \n" | while read line
                        		do
                                		if  [ $(echo $line | awk '{ print $3 }') -gt 100 ]
                                        		then
                                                		echo "$line" >> /tmp/warning_list.txt
                                		fi
                        		done
			else
				${0##*/} -h
                                exit 1
		
		fi
	
                if [ -f /tmp/warning_list.txt ]
                        then	
                                cat "/tmp/warning_list.txt" | mail -s "[/scratch/daint] Warning: users in the attached list are using more then 100Tb of disk space" -a /tmp/warning_list.txt fverzell@cscs.ch
                                rm /tmp/warning_list.txt
                fi

		;;
	
	"-h" | "--help" )
                        ${0##*/}
                        exit 1
                        ;;

        * )
                        msg "usage: ${0##*/} -c {script for cron, email recipient has to be specified into the script} "
                        msg "usage: ${0##*/} -o {to print the result in the stdout} "
                        msg "usage: ${0##*/} -e "email@email.ch" {to send the output via email}"
                        exit 1
                        ;;
esac
exit 0
