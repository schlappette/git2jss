#!/bin/bash

#restart lce services

launchctl unload /Library/LaunchDaemons/com.tenable.launchd.lceclient.plist &> /dev/null

launchctl load -w /Library/LaunchDaemons/com.tenable.launchd.lceclient.plist 

exit