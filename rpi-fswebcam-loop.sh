#!/bin/bash

# rpi-fswebcam.sh
# by wilsonmar@gmail.com
# based on https://www.raspberrypi.org/documentation/usage/webcams/
# Run with commands:
#    chmod +x rpi-fswebcam.sh
#    ./rpi-fswebcam.sh

# Loop and wait:
i=1
RES="640x480" #RES="320x240" # depending on the camera: 1280x720 
SLEEP_SECS=60
echo "Take a $RES picture every $SLEEP_SECS seconds:"
while [ "$i" -ne 0 ] # infinite loop
do
   # Make sure there is enough disk space using Bash df command:
   GB_AVAIL=$(df -h|grep '^/dev/root'|awk '{ print $5}'|sed 's/%//'|cut -d '%' -f1 )
         # sed s(ubstitute)/search/replacestring/
   	  echo "$GB_AVAIL percent free."

   # Exit if there is not enough disk space:
   if [ "$GB_AVAIL" -lt 5 ]; then
   	  echo "$GB_AVAIL GB not enough space available for this."
   	  exit
   else # go on:
     DATE=$(date +"%Y-%m-%d_%H_%M")
     FILE_NAME="fswebcam-$DATE-$i-$RES.jpg"
     echo $FILE_NAME
     fswebcam -r $RES $FILE_NAME
     # fswebcam -r $RES --no-banner $FILE_NAME
     echo "Sleeping $SLEEP_SECS seconds ... Press control+C to stop."
     sleep $SLEEP_SECS # seconds
     i=`expr $i + 1`

     # TODO: Check if there is a difference in the pictures
     #       If none, delete prior file.
     #       If there is a difference, email both pictures
   fi
done
#fswebcam -r $RES --no-banner /home/pi/fswebcam-$DATE.jpg
# Writing JPEG image to '/home/pi/webcam/2013-06-07_2338.jpg'.

# To run on a schedule, open the cron table for editing:
#    crontab -e
# 
# This will either ask which editor you would like to use, or 
# open in your default editor. Once you have the file open in an editor, 
# add the following line to schedule taking a picture every minute 
# (referring to the Bash script from above):

#    * * * * * /home/pi/webcam.sh 2>&1

# Save and exit and you should see the message:

#    crontab: installing new crontab

# Ensure your scipt does not save each picture taken with the same filename. 
# This will overwrite the picture each time.