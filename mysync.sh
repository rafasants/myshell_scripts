#!/bin/bash

# < AUTHOR: RAFAEL >

# This script is aimed to facilitate the backup of my spreadsheet to Cloud (Google Drive) using insync. But you can use this for any file, just configure the variables.

INSYNC=$(pgrep insync)

if [ -z "$INSYNC" ]
        then
                insync &
		sleep 30
fi

### VARIABLES ###

# YOU CAN CHANGE THIS WHITH YOUR ENVIRONMENT.

CLOUD_DIRECTORY="/home/rafael/Insync/comprasml159@gmail\.com/Google\ Drive/CONTROLE_GASTOS/"
LOCAL_DIRECTORY="/media/sf_virtual/GOOGLE_DRIVE/CONTROLE_GASTOS/"
FILE_NAME="2019.xlsm"
LOCAL_FILE_DATE=$(eval date -r $LOCAL_DIRECTORY$FILE_NAME "+%d%m%y%H%M%S")
CLOUD_FILE_DATE=$(eval date -r $CLOUD_DIRECTORY$FILE_NAME "+%d%m%y%H%M%S")
LOG_FILE="/home/rafael/Insync/Insync.log"

# DON'T CHANGE FROM HERE!

if [ "$LOCAL_FILE_DATE" == "$CLOUD_FILE_DATE" ]
	then
		xmessage -timeout 10 "No Changes!"
		pkill insync
		exit 0
fi
if [ "$LOCAL_FILE_DATE" -gt "$CLOUD_FILE_DATE" ]
	then
		xmessage -timeout 10 "LOCAL FILE IS MORE RECENT. STARTING UPLOAD TO CLOUD!"
		sleep 2
		eval cp -pf $LOCAL_DIRECTORY$FILE_NAME $CLOUD_DIRECTORY >> $LOG_FILE 2>&1
		if [ $? -ne "0" ]
			then
		  	       xmessage -timout 10 "An error ocurred. Please read the File Log!"
			       pkill insync
			       exit 1
			else
				sleep 40
				xmessage -timeout 10 "Update Successful!"
				exit 0
		fi
fi
if [ "$CLOUD_FILE_DATE" -gt "$LOCAL_FILE_DATE" ]
	then
		xmessage -timeout 10 "CLOUD FILE IS MORE RECENT. STARTING DOWNLOAD TO FILE FOLDER!"
		sleep 2
		eval sudo cp -pf $CLOUD_DIRECTORY$FILE_NAME $LOCAL_DIRECTORY >> $LOG_FILE 2>&1
		if [ $? -ne "0" ]
                        then
                               xmessage -timeout 10 "An error ocurred. Please read the File Log!"
			       pkill insync
                               exit 1
                        else
				sleep 30
                                xmessage -timeout 10 "Update Successful!"
                                exit 0
                fi
fi

exit 0
