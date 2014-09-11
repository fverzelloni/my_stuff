#!/bin/bash

###########################################
# Who touch, what?
# Rev 1.0 - Fabio Verzelloni 9th Feb 2011
###########################################

TOUCH=$(/bin/.touch "$@")
pwd | while read input ; do
echo $input | grep scratch > /dev/null

if  $? = 0 
    then
    $TOUCH
    echo "$(whoami) touched $@ on $(date +%d%m%y)" >> $SCRATCH/tinfo/tinfo_ela.log
else
    echo $@ | grep scratch > /dev/null
        if  $? = 0 
        then
            $TOUCH
            echo "$(whoami) touched $input/$@ $(date +%d%m%y)" >> $SCRATCH/tinfo/tinfo_ela.log
        else
            $TOUCH
        fi
fi
done
