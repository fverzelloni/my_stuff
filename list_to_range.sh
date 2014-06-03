#!/bin/bash 

numbers="18,19,62,161,162,163,165"
echo $numbers, | sed "s/,/\n/g" | while read num; do
    if [[ -z $first ]]; then
        first=$num; last=$num; continue;
    fi
    if [[ num -ne $((last + 1)) ]]; then
        if [[ first -eq last ]]; then echo $first; else echo $first-$last; fi
        first=$num; last=$num
    else
        : $((last++))
    fi
done | paste -sd ","
