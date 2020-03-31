#!/usr/bin/python3

import platform
import sys
import os
import fileinput
import subprocess
import socket
from subprocess import Popen, PIPE
#from shutil import which

#Variables
http_srv = 'someo.cscs.ch'
hostname = platform.node()

#Functions
def check_program_exists(name):
    p = Popen(['/usr/bin/which', name], stdout=PIPE, stderr=PIPE)
    p.communicate()
    return p.returncode == 0

# Save output in /tmp/sys_info_HOSTNAME.html
sys.stdout = open('/tmp/sys_info_'+hostname.split(".")[0]+'.html','w')

# Get IP
host_ip = socket.gethostbyname(hostname)

# Architecture
arch = platform.architecture()[0]

# Linux Distribution
distro = str(platform.linux_distribution())

# Kernel Version
kernel = str(platform.release())

# Distribution
dist = platform.dist()
dist = " ".join(x for x in dist)

# Processor
with open("/proc/cpuinfo", "r")  as f:
    info = f.readlines()
cpuinfo = [x.strip().split(":")[1] for x in info if "model name"  in x]

# Memory
#print("Memory Info: ")
with open("/proc/meminfo", "r") as f:
    lines = f.readlines()
    memtotal = lines[0].split()
    memfree = lines[1].split()
    memtotal = ( int(memtotal[1]) / 1024 / 1024 )
    memfree = ( int(memfree[1]) / 1024 / 1024 )

# Uptime
uptime = None
with open("/proc/uptime", "r") as f:
    uptime = f.read().split(" ")[0].strip()
uptime = int(float(uptime))
uptime_hours = uptime // 3600
uptime_minutes = (uptime % 3600) // 60

# Load
with open("/proc/loadavg", "r") as f:
    load = f.read().strip()

# Create HTML
print("<html>")
print("<br>")
print("<b>"+ hostname + "</b>")
print("<br>")
print("Hostname: " + hostname)
print("<br>")
print("Ip Address: " + host_ip)
print("<br>")
print("Architecture: " + arch)
print("<br>")
print("Distribution: " + dist)
print("<br>")
print("Kernel: " + kernel)
print("<br>")
#BCM Version
if check_program_exists('cmsh') == True:
    bcmver = subprocess.getoutput('cmsh -c "main versioninfo"')
    bcmver_split = (bcmver.splitlines())
    #print(type(bcmver_split))
    for x in bcmver_split:
        if "Manager" in x:
            print("BCM Version: " + x.split()[2] + "<br>" )
#Slurm Version
if check_program_exists('sinfo') == True:
    slurmver = subprocess.getoutput('sinfo -V')
    print("<br>")
    print("Slurm Version: " + slurmver.split()[1] )
    print("<br>")
#GPFS Version
if check_program_exists('mmdiag') == True:
    gpfsver = subprocess.getoutput('mmdiag --version')
    gpfsver_split = (gpfsver.splitlines())
    for x in gpfsver_split:
        if "Current" in x:
            print(x)
            print("<br>")
#Uptime
print("Uptime: " + str(uptime_hours) + ":" + str(uptime_minutes) + " hours")
print("<br>")
#Load
print("Average Load: " + load)
print("<br>")
#Memory
print("Memory Total: " + str(int(memtotal)) + ' GB')
print("<br>")
print("Memory Free: " + str(int(memfree)) + ' GB')
print("<br>")
print("</html>")
sys.stdout.close()

# Copy HTML to remote server
p = subprocess.Popen(['scp', '/tmp/sys_info_'+hostname.split(".")[0]+'.html', 'root@'+ http_srv +':/var/www/html/confluence/sys_info_'+hostname.split(".")[0]+'.html'])
sts = p.wait()

# Delete files from /tmp
os.remove('/tmp/sys_info_'+hostname.split(".")[0]+'.html')

#print("Processors: ")
#for index, item in enumerate(cpuinfo):
#    print("    " + str(index) + ": " + item)
#print("    " + str(index) + ": " + item))
#print("<br>")
