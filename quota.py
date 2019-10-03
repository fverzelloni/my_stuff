####!/usr/bin/python3

import re
import subprocess

# debug & test
#groups = 'uid=1600030(bp000029) gid=1600000(bp0) groups=1600000(bp0),32104(ich011),31882(ich002),1600067(bp00sp01)'
#cmd = subprocess.getoutput('/usr/bin/id bp000029')
#cmd_split = cmd.split("groups",1)[1]
#account = re.findall('\(([^)]+)', cmd_split)

def get_quota(config, LOG):
#def get_quota():
    cmd = subprocess.getoutput('/usr/bin/id $USER')
    cmd_split = cmd.split("groups",1)[1]
    account = re.findall('\(([^)]+)', cmd_split)
    totalh = 0.0
    for i in account:
        line = '/apps/common/system/sbin/sbucheck_adm -g ' + i + ' | grep -w "DAINT Usage" | awk \'{print $8 \" \" $3}\''
        data = subprocess.getoutput(line)
        datas = data.split(' ')
        if datas:
            tot_node_hours = float(datas[0].replace(',', ''))
            consumed_node_hours = float(datas[1].replace(',', ''))
            remaining_node_hours = tot_node_hours - consumed_node_hours
        else:
            LOG.error("Error determining CPU quota: %s", data)
            return str(000000)
    return int(remaining_node_hours)

#print(get_quota())
print(get_quota())
