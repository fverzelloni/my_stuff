#!/bin/bash -l

pathtowith=5

xtprocadmin |grep down | tr "," "\n" | awk '{ print $1" "$5" "$3 }' > list1

cat list1 | awk '{ print $1 }' | while read line ; do printf "nid%0*d\n" $pathtowith $line ; done > list3

paste list3 list1 | column -s $'\t' -t | awk '{ print $1","" "","" "","" "","" "","" ""," $3" "","$4 }'
