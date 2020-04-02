#!/usr/bin/python3
import os
import shutil
import glob
import pandas as pd

file_to_conv = (glob.glob("/tmp/sys_info_*.csv"))
for x in file_to_conv:
    files_lst = (os.path.split(x)[1])
    df = pd.read_csv('/tmp/'+files_lst, sep=';' )
    df.to_html('/var/www/html/confluence/'+files_lst.split(".")[0]+'.html')
    htmTable = df.to_html()
