#!/bin/bash

# Install Adobe AIR

# Setting Variables
dmgfile="AdobeAIR.dmg"
volname="Adobe AIR"
url='https://airdownload.adobe.com/air/mac/download/latest/AdobeAIR.dmg'

#Download DMG to /tmp
curl -s -o /tmp/${dmgfile} ${url}
# Mount DMG
hdiutil attach /tmp/${dmgfile} -nobrowse -quiet
# Uninstall DMG Payload (.pkg or .app)
"/Volumes/${volname}/Adobe AIR Installer.app/Contents/MacOS/Adobe AIR Installer" -silent -eulaAccepted
# Pause for 3 sec
sleep 10
# Unmount DMG
hdiutil detach $(df | grep "${volname}" | awk '{print $1}') -quiet
# Delete DMG from /tmp
sleep 10
rm /tmp/"${dmgfile}"

exit 0
