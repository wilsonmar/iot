#!/usr/bin/env python
# twitter_send.py in https://github.com/wilsonmar/io
# by wilsonmar@gmail.com, 

# Based on https://www.raspberrypi.org/learning/getting-started-with-the-twitter-api/worksheet/

from datetime import datetime
#from pytz import timezone
#import pytz
# https://pypi.python.org/simple/pytz/ # for time zones.
# http://pytz.sourceforge.net/

# Uncomment when Twython is working:
#from twython import Twython
# sudo easy_install twython
# https://twython.readthedocs.io/en/latest/
# https://github.com/ryanmcgrath/twython
# http://stackoverflow.com/questions/tagged/twython

import sys # for sys.argv[0] 

# In a file named .twitter_wilsonmar_keys.py:
# in https://apps.twitter.com/ Create New App https://www.raspberrypi.org/
# with Read/Write permissions.
# twitter_account     = 'wilsonmar'
# consumer_key        = '?'
# consumer_secret     = '?'
# access_token        = '?'
# access_token_secret = '?'

exec open(".twitter_api_secret_keys").read()
print "Twitter account: %s" % twitter_account
# don't print secrets consumer_key, consumer_secret, access_token, access_token_secret
exit

# WARNING: Running this automatically creates a compiled bytecode file named
  # twitter_api_secret_keys.pyc
#from twitter_api_secret_keys import (
#    twitter_account,
#    consumer_key,
#    consumer_secret,
#    access_token,
#    access_token_secret
#)

# Uncomment when Twython is working:
#twitter = Twython(
#    consumer_key,
#    consumer_secret,
#    access_token,
#    access_token_secret
#)

def get_pi_serial():
      # Extract serial from cpuinfo file
  cpuserial = "0000000000000000"
  try:
    f = open('/proc/cpuinfo','r')
    for line in f:
      if line[0:6]=='Serial':
        cpuserial = line[10:26]
    f.close()
  except:
    cpuserial = ""
  return cpuserial.lstrip("0")

# Uses the API's update_status() function to send a tweet:
# The preferred way of dealing with times is to always work in UTC, converting to localtime only when generating output to be read by humans.
d = datetime.utcnow() # 
    #utc_dt = datetime(2002, 10, 27, 6, 0, 0, tzinfo=utc)
message = "@"+twitter_account +" hello from " +sys.argv[0] +" "+ get_pi_serial()+" "+d.isoformat("T") + "Z"
    # Sample: 2016-11-24T22:19:51.112542Z where the 112542+00:00
    #d=datetime.now(timezone.utc).astimezone().isoformat()
#then = datetime.now(pytz.utc)
#print(then.astimezone(pytz.timezone('US/Mountain'))) # '2015-01-27T06:59:17.125448-05:00' for US/Eastern

# Uncomment when Twython is working:
# twitter.update_status(status=message)
print("Tweeted: %s" % message)
