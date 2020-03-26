#!/usr/local/bin/confluence/env/bin/python3

import platform
import sys
import os
import fileinput
import subprocess

#Variables
http_srv = 'someo.cscs.ch'
hostname = platform.node()

# Save output in /tmp/sys_info_HOSTNAME.html
sys.stdout = open('/tmp/sys_info_'+hostname.split(".")[0]+'.html','w')

# Architecture
arch = platform.architecture()[0]

# Linux Distribution
distro = str(platform.linux_distribution())

# Kernel Version
kernel = str(platform.release())

# distribution
dist = platform.dist()
dist = " ".join(x for x in dist)

# processor
#print("Processors: ")
with open("/proc/cpuinfo", "r")  as f:
    info = f.readlines()
cpuinfo = [x.strip().split(":")[1] for x in info if "model name"  in x]

# Memory
#print("Memory Info: ")
with open("/proc/meminfo", "r") as f:
    lines = f.readlines()

#print("     " + lines[0].strip())
#print("     " + lines[1].strip())

# uptime
uptime = None
with open("/proc/uptime", "r") as f:
    uptime = f.read().split(" ")[0].strip()
uptime = int(float(uptime))
uptime_hours = uptime // 3600
uptime_minutes = (uptime % 3600) // 60
#print("Uptime: " + str(uptime_hours) + ":" + str(uptime_minutes) + " hours")

# Load
with open("/proc/loadavg", "r") as f:
    load = f.read().strip()
#    print("Average Load: " + f.read().strip())
print("<html>")
print("<br>")
print("Hostname: " + hostname)
print("<br>")
print("Architecture: " + arch)
print("<br>")
print("Distribution: " + dist)
print("<br>")
print("Kernel: " + kernel)
print("<br>")
print("Uptime: " + str(uptime_hours) + ":" + str(uptime_minutes) + " hours")
print("<br>")
print("Processors: ")
for index, item in enumerate(cpuinfo):
    print("    " + str(index) + ": " + item)
#print("    " + str(index) + ": " + item))
print("<br>")
print("Average Load: " + load)
print("<br>")
print("Memory Info: ")
print("     " + lines[0].strip())
print("     " + lines[1].strip())
print("</html>")
sys.stdout.close()

#os.rename('/tmp/sys_info.html','/tmp/sys_info_'+hostname.split(".")[0]+'.html')

# Copy HTML to remote server
p = subprocess.Popen(['scp', '/tmp/sys_info_'+hostname.split(".")[0]+'.html', 'root@'+ http_srv +':/var/www/html/confluence/sys_info_'+hostname.split(".")[0]+'.html'])
sts = p.wait()

# Delete files from /tmp
os.remove('/tmp/sys_info_'+hostname.split(".")[0]+'.html')
