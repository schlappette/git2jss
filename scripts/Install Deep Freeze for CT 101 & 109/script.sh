#!/bin/bash
#################################################
# Install Script - Deep Freeze 7 (APFS) for CT 101-109
#
# Info: This script will install Deep Freeze 7.
# It will perform the following:
# - Check if filesystem is APFS, will exit if HFS
# - Install Deep Freeze from pkg
# - Set license key
# - Create Global Thawspace
# 
# THIS WILL NOT FREEZE THE SYSTEM!


#Caffeinate!!!
caffeinate -dis &
caffeinatePID=$(echo $!)

#Change to payload directory
cd "/private/tmp/DF7/"

#Setting Variables
dflicense=$(tail -1 LicenseInformation.txt)

###############################################################
#Check FileSystem. Proceed if APFS, exit if HFS.

filesys=$(/usr/libexec/PlistBuddy -c "Print :FilesystemType" /dev/stdin <<< $(diskutil info -plist /))

if [ "$filesys" == "apfs" ]
  then
    #Install Deep Freeze 7
    installer -pkg "Deep Freeze Mac 7.01.220.0054.pkg" -target /;
    sleep 5
    #Set license key
    /usr/local/bin/deepfreeze license --set $dflicense
    #Create Global Thawspace
    /usr/local/bin/deepfreeze thawspace create --global
  else
    #Write to Jamf Log and exit
    echo  "Mac is currently on the HFS file system. Deep Freeze 7 requires APFS file system to install. Exiting... " >> /var/log/jamf.log
    kill $caffeinatePID
    cleanup.sh &
    exit 1
fi

kill $caffeinatePID
cleanup.sh &
