#!/Library/Frameworks/Python.framework/Versions/3.7/bin/python3

# This code sample uses the 'requests' library:
# http://docs.python-requests.org
import requests
import json
import configparser
import os

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

#Variables
url = "https://confluence-tds.cscs.ch/rest/api/content/118620161"
config_items = import_config_file('config.ini')
conf_tds_username = config_items['credentials'] ['conf_tds_username']
conf_tds_password = config_items['credentials'] ['conf_tds_password']
conf_username = config_items['credentials'] ['conf_username']
conf_password = config_items['credentials'] ['conf_password']
conf_tds_url = config_items['urls'] ['conf_tds_url']
conf_url = config_items['urls'] ['conf_url']

with open('test_html_table4.txt', 'r') as file:
    data = file.read()
#print(data)

# Confluence push
headers = {
   "Accept": "application/json",
   "Content-Type": "application/json"
}

payload = json.dumps( {
  "version": {
    "number": 37
  },
  "title": "[ Unicore ] XUUDB Unicore ",
  "type": "page",
  "status": "current",
  "body": {
    "storage": {
      "value": data,
      "representation": "storage"
    },
  }
} )

response = requests.request(
   "PUT",
   url,
   data=payload,
   headers=headers,
   auth=(conf_tds_username, conf_tds_password)
)

print(json.dumps(json.loads(response.text), sort_keys=True, indent=4, separators=(",", ": ")))
