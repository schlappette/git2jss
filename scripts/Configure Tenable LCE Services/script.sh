#!/bin/bash

#setup IP and port
/opt/lce_client/set-server-ip.sh vmsytenablelce01.pcc.edu 31300 &> /dev/null

#restart lce services

launchctl unload /Library/LaunchDaemons/com.tenable.launchd.lceclient.plist &> /dev/null

launchctl load -w /Library/LaunchDaemons/com.tenable.launchd.lceclient.plist 

exit