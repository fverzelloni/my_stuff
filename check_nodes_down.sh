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
<<<<<<< HEAD

echo $result
=======
>>>>>>> 44efd7982a51f6d089247ad1e85afb6fe6f5350f
