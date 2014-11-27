#!/bin/bash

#
# ********************************************************************
# * 001 * 10-09-14 * Fabio Verzelloni / CSCS  * File created         *
# * 002 * 27-11-14 * Fabio Verzelloni / CSCS  * Version 1.1          *
# * 003 *          *                          *                      *
# ********************************************************************
#
#---------------------------------------------------------------------
# CONFIGURATION
#---------------------------------------------------------------------
TODAY=$(date +%Y-%m-%d)
HOSTNAME=$(hostname | sed 's/[0-9]//g')
WARN_DATE1=$(date -d "+5 days" "+%Y-%m-%d")
WARN_DATE2=$(date -d "+6 days" "+%Y-%m-%d")
MAINTDAY2=$(cat maint.txt | grep $WARN_DATE2 | awk '{ print $1 }' )
MAINTDAY1=$(cat maint.txt | grep $WARN_DATE1 | awk '{ print $1 }' )
RES_CHECK=$(scontrol show res=maint)
HOSTNAME=$(hostname | sed 's/[0-9]//g')

#---------------------------------------------------------------------
# DECLARE RECIPIENT
#---------------------------------------------------------------------
case "$1" in
	daint)
		RECIPIENT=fverzell@cscs.ch
		;;
	dora)
		RECIPIENT=fverzell@cscs.ch,nbianchi@cscs.ch,annaloro@cscs.ch
		;;
	julier)
		RECIPIENT=cponti@cscs.ch,annaloro@cscs.ch
		;;
	pilatus)
		RECIPIENT=cponti@cscs.ch,annaloro@cscs.ch
		;;
	todi)	
		RECIPIENT=induni@cscs.ch,cponti@cscs.ch
		;;
        *)
		echo "usage: ${0##*/} MACHINE"
		exit 1
		;;
	help)
		echo "usage: ${0##*/} MACHINE"
		exit 1
                ;;
esac



#---------------------------------------------------------------------
# SCRIPT
#---------------------------------------------------------------------
if [  "$WARN_DATE2" == "$MAINTDAY2" ]
	then
		if [ -n "grep $HOSTNAME maint.txt" ]
			then
				if [ "$RES_CHECK" == "Reservation maint not found" ]
					then
						echo -e "No 'maint' reservation on $HOSTNAME, your system will be under maintenance the next $MAINTDAY2, remember to create the 'maint' reservation: \n \nscontrol create res=maint starttime="$MAINTDAY2"T08:00:00 duration=10:00:00 nodes=all accounts=csstaff,cray,usup flag=maint,overlap" | mail -s "Reservation 'maint' not present on $HOSTNAME" $RECIPIENT
				fi
		fi
else
	if [ "$WARN_DATE1" == "$MAINTDAY1" ]
		then
                       	if [ -n "grep $HOSTNAME maint.txt" ]
                               	then
             		                if [ "$RES_CHECK" == "Reservation maint not found" ]
               	                               	then
         	                                       	echo -e "No 'maint' reservation on $HOSTNAME, your system will be under maintenance the next $MAINTDAY1, remember to create the 'maint' reservation: \n \n scontrol create res=maint starttime="$MAINTDAY1"T08:00:00 duration=10:00:00 nodes=all accounts=csstaff,cray,usup flag=maint,overlap" | mail -s "Reservation 'maint' not present on $HOSTNAME" $RECIPIENT

                                         fi
                        fi
	fi
fi
