#!/usr/bin/python3

import platform
import sys
import os
import fileinput
import subprocess
import socket
import platform
from subprocess import Popen, PIPE

#Variables
http_srv = 'someo.cscs.ch'
hostname = platform.node()

##Functions
def check_program_exists(name):
    p = Popen(['/usr/bin/which', name], stdout=PIPE, stderr=PIPE)
    p.communicate()
    return p.returncode == 0

# Save output in /tmp/sys_info_HOSTNAME.html
sys.stdout = open('/tmp/sys_info_'+hostname.split(".")[0]+'.html','w')

# Get IP
host_ip = socket.gethostbyname(hostname)
# Linux Distribution
distro = str(platform.linux_distribution())
# Kernel Version
kernel = str(platform.release())
# Distribution
dist = platform.dist()
dist = " ".join(x for x in dist)
# Memory
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

##
# Create HTML
print("<html>")
print("<b>"+ hostname + "</b>")
print("<br> Hostname: " + hostname )
print("<br> Ip Address: " + host_ip )
#Processors
if check_program_exists('lscpu') == True:
    cpuinfo = subprocess.getoutput('lscpu')
    cpuinfo_split = (cpuinfo.splitlines())
    values = ["Architecture:", "CPU(s):", "Model name:", "Core(s) per socket:", "Thread(s) per core:" ]
    for x in cpuinfo_split:
        for y in values:
            if y in x:
                print("<br>" + x)
print("<br> Distribution: " + dist )
print("<br> Kernel: " + kernel )
#print("<br>" + platform.processor() )
#BCM Version
if check_program_exists('cmsh') == True:
    bcmver = subprocess.getoutput('cmsh -c "main versioninfo"')
    bcmver_split = (bcmver.splitlines())
    for x in bcmver_split:
        if "Manager" in x:
            print("<br> BCM Version: " + x.split()[2] )
#Slurm Version
if check_program_exists('sinfo') == True:
    slurmver = subprocess.getoutput('sinfo -V')
    print("<br> Slurm Version: " + slurmver.split()[1] )
    print("<br>")
#GPFS Version
if check_program_exists('mmdiag') == True:
    gpfsver = subprocess.getoutput('mmdiag --version')
    gpfsver_split = (gpfsver.splitlines())
    for x in gpfsver_split:
        if "Current" in x:
            print(x)
#CUDA Version
if check_program_exists('nvcc') == True:
    cudaver = subprocess.getoutput('nvcc --version')
    cudaver_split = (cudaver.splitlines())
    for x in cudaver_split:
        if "release" in x:
            print("<br> CUDA Version: " + x.split(' ')[5] )
#NVIDIA Driver Version
if check_program_exists('nvidia-smi') == True:
    nvidiadrv = subprocess.getoutput('nvidia-smi')
    nvidiadrv_split = (nvidiadrv.splitlines())
    for x in nvidiadrv_split:
        if "Driver Version" in x:
            print("<br> NVIDIA Driver Version: " + x.split()[5])
#Uptime
print("<br> Uptime: " + str(uptime_hours) + "h" ":" + str(uptime_minutes) + "m")
#Load
print("<br> Average Load: " + load )
#Memory
print("<br> Memory Total: " + str(int(memtotal)) + ' GB')
print("<br> Memory Free: " + str(int(memfree)) + ' GB')
print("</html>")
sys.stdout.close()

# Copy HTML to remote server
p = subprocess.Popen(['scp', '/tmp/sys_info_'+hostname.split(".")[0]+'.html', 'root@'+ http_srv +':/var/www/html/confluence/sys_info_'+hostname.split(".")[0]+'.html'])
sts = p.wait()

# Delete files from /tmp
os.remove('/tmp/sys_info_'+hostname.split(".")[0]+'.html')
