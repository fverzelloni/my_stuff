#!/usr/bin/env python

import sys
file1 = sys.argv[1]; file2 = sys.argv[2]; outfile = sys.argv[3]

def readfile(file):
    with open(file) as compare:
        return [item.replace("\n", "").split(" ") for item in compare.readlines()]

data1 = readfile(file1); data2 = readfile(file2)
mismatch = [item[0] for item in data1 if not item in data2]

with open(outfile, "wt") as out:
    for line in mismatch:
        out.write(line+" has changed"+"\n")
