#!/bin/bash


# prevent GUI from opening on start
sed -i.bak '/RunAtLoad/{n;s/.*/        <false\/>/;}' /Library/LaunchAgents/com.checkpoint.eps.gui.plist
sed -i.bak '/RunAtLoad/{n;s/.*/        <false\/>/;}' /Library/LaunchDaemons/com.checkpoint.epc.service.plist

rm /Library/LaunchDaemons/com.checkpoint.epc.service.plist.bak
rm /Library/LauchAgents/com.checkpoint.eps.gui.plist.bak

# $SERVICE is running. Shut it down
launchctl unload /Library/LaunchDaemons/com.checkpoint.epc.service.plist
kextunload /Library/Extensions/cpfw.kext

# $SERVICE is not running. Fire it up
launchctl load /Library/LaunchDaemons/com.checkpoint.epc.service.plist
kextload /Library/Extensions/cpfw.kext

sleep 1

/Library/Application\ Support/Checkpoint/Endpoint\ Connect/command_line disconnect