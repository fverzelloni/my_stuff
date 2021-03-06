#!/usr/local/bin/confluence/env/bin/python3
# This script sync users with access to Daint and HBP account
# with the XUUDB using both CN & UID account
# 17.03.20 - Fabio Verzelloni

import requests
import json
import time
import sys
import os
import urllib3
import configparser
import subprocess
import smtplib
import argparse
import pandas as pd
from email.message import EmailMessage

# Suppress ssl Warnings
urllib3.disable_warnings()

# Function to import configurations and credentials from .ini file
def import_config_file(conf_file):
    '''Given a configuration file return an object containing the configuration items'''
    if os.path.isfile(conf_file):
        config = configparser.ConfigParser()
        config.read(conf_file)
        return config
    else:
        # Print error on cosole because at this point the logging is not yet setup
        print('Unable to read configuration file {}'.format(conf_file))
        sys.exit(1)


# Variables
config_items = import_config_file('/usr/local/bin/confluence/config.ini')
ump_username = config_items['credentials'] ['ump_username']
ump_password = config_items['credentials'] ['ump_password']
hbp_username = config_items['credentials'] ['hbp_username']
hbp_password = config_items['credentials'] ['hbp_password']
ump_url = config_items['urls'] ['ump_url']
hbp_url = config_items['urls'] ['hbp_url']
users_to_skip = ['bp000094', 'bp000096', 'bp000235', 'ich019sa', 'bp000095' ]
http_srv = 'someo.cscs.ch'

# Functions
def get_ump_users():
    '''Get active users list from UMP RestAPI'''
    payload = {'projectGroupStatus': 'ACCESSIBLE+OPEN+EXPIRING', 'userStatus': 'ACTIVE+EXPIRING', 'facilityId': 'DAINT'}
    #start_function = time.time()
    resp = requests.get('{}v2/bulk/user-list-by-facility'.format(ump_url), params=payload, auth=(ump_username, ump_password), timeout=10)
    #end_function = time.time()
    if resp.status_code != 200:
        print('Error! UMP RestAPI responded with: {}'.format(resp.status_code))
        sys.exit(1)
    else:
        jData = resp.json()['body']['map']
        #print('Downloaded users data from UMP RestAPI. (Time: {})(Size: {} bytes)'.format(end_function - start_function, sys.getsizeof(jData)))
        return jData


def get_hbp_data(username):
    '''Get users info from HBP RestAPI'''
    #start_function = time.time()
    resp = requests.get('{}hpcmanagement/v1/accounts/{}'.format(hbp_url, username), auth=(hbp_username, hbp_password), timeout=20, verify=False)
    print(resp)
    #end_function = time.time()
    if resp.status_code != 200:
        print('Error! HBP RestAPI responded with: {}'.format(resp.status_code))
        sys.exit(1)
    else:
        jData = resp.json()
        #print('Downloaded users data from HBP RestAPI. (Time: {})(Size: {} bytes)'.format(end_function - start_function, sys.getsizeof(jData)))
        return jData

def get_xuudb_users():
    '''Get users from XUUDB'''
    start_function = time.time()
    subprocess.call('/opt/Unicore/default/xuudb/bin/admin.sh export /tmp/xuudb_export.csv', shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

# Generate parsed xuudb_export.csv list
get_xuudb_users()
bp_users_list_xuudb = []
with open('/tmp/xuudb_export.csv', 'r') as f:
    file_content = f.readlines()
    for line in file_content:
        if "bp00" not in users_to_skip:
            if "bp00" in line:
                bp_users_list_xuudb.append(line.rstrip().split(';')[2])

# Create dictionary obj "ump_data" calling the function get_ump_users()
ump_data = get_ump_users()
#print(ump_data)
#print(json.dumps(ump_data['fverzell'], indent=2))
#print(json.dumps(ump_data['fverzell']['accesses'], indent=2))


# Generate list with bpxx users
bp_users_list_ump = []
for x in ump_data:
    if "bp00" in x:
        bp_users_list_ump.append(x)

# Create list of users to add and delete using "sets"
users_to_add = set(bp_users_list_ump).difference(bp_users_list_xuudb)
users_to_del = set(bp_users_list_xuudb).difference(bp_users_list_ump)
#print(f'Utenti da aggiunere : {list(users_to_add)}')
#print(f'Utenti da cancellare: {list(users_to_del)}')

# Generate and store list users to add
def generate_add_list():
    users_list_add = []
    if len(users_to_add) != 0:
        for user in users_to_add:
            if user not in users_to_skip:
                user_data = get_hbp_data(user)
                displayname = user_data['displayName']
                email = user_data['mail']
                uid = user_data['owner'].split(',')[0].replace('uid=', '')
                users_list_add.append(f'/opt/Unicore/default/xuudb/bin/admin.sh adddn DAINT-CSCS "CN={displayname} {uid},O=hbp" {user} user')
                users_list_add.append(f'/opt/Unicore/default/xuudb/bin/admin.sh adddn DAINT-CSCS "UID={email}" {user} user')
    return users_list_add
    #return line

# Generate and store list users to del
def generate_del_list():
    users_list_del = []
    if len(users_to_del) != 0:
        for user in users_to_del:
            users_list_del.append(f'/opt/Unicore/default/xuudb/bin/admin.sh remove xlogin={user}')
    return users_list_del

# FV commented out 6 lines below
users_new_email = generate_add_list()
users_del_email = generate_del_list()
users_del_email = generate_del_list()
list_total_str = '\n'.join(users_new_email + users_del_email)
subprocess.getoutput(list_total_str)
xuudb_list = subprocess.getoutput('/opt/Unicore/default/xuudb/bin/admin.sh list | tail -n 10')

# Send email add & delete
def send_email():
    msg = EmailMessage()
    msg.set_content('Following the users that have been added/deleted to XUUDB: \n \n' + list_total_str + '\n Last 10 lines from admin.sh list command: \n \n' + xuudb_list)
    msg['Subject'] = 'XUUDB Accounts added & deleted'
    msg['From'] = 'fusco.cscs.ch'
    msg['To'] = 'fverzell@cscs.ch'
    #msg['To'] = 'fverzell@cscs.ch, minduni@cscs.ch'
    s = smtplib.SMTP('smtp.cscs.ch', 25)
    s.send_message(msg)
    s.quit()

# Initialize the parser
#parser = argparse.ArgumentParser()
#parser.add_argument('-s', '--send', action='store_true', help="Send email with users to add in XUUDB")
#parser.add_argument('-p', '--print', action='store_true', help="Print commnad to add and delete users from XUUDB")\

# FV commented out 2 lines below
if len(list_total_str) != 0:
        send_email()

## Read and convert to HTML the CSV file
# Read the csv file in
df = pd.read_csv('/tmp/xuudb_export.csv', sep=';' )

# Save to file
df.to_html('/tmp/xuudb.html')

# Assign to string
htmTable = df.to_html()

# Copy HTML to remote server
p = subprocess.Popen(['scp', '/tmp/xuudb.html', 'root@'+ http_srv +':/var/www/html/confluence/xuudb.html'])
sts = p.wait()
########################################

# Delete .csv file from /tmp
os.remove('/tmp/xuudb_export.csv')
