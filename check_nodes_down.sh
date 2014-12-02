#~/bin/bash

STATE_OLD=/tmp/current
STATE_NOW=/tmp/old

result=$(comm -2 $STATE_NOW $STATE_OLD )

if [ $? -eq 0 ]
then
        echo "files are the same"
else
        echo "files are different"
        echo "$result"
fi
