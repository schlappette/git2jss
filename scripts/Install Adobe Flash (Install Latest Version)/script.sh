#!/bin/bash

############################################################################################################################
# Set Variables
npapidmg="install_flash_player_osx.dmg"
#ppapidmg="install_flash_player_osx_ppapi.dmg"
npapivol="Flash Player"
#ppapivol="Flash Player"

# Direct Download Links
npapiurl='https://fpdownload.macromedia.com/pub/flashplayer/latest/help/install_flash_player_osx.dmg'
#ppapiurl='https://fpdownload.macromedia.com/pub/flashplayer/latest/help/install_flash_player_osx_ppapi.dmg'

############################################################################################################################
# Download DMG files
curl -s -o /tmp/${npapidmg} ${npapiurl}
#curl -s -o /tmp/${ppapidmg} ${ppapiurl}

############################################################################################################################
# Install Adobe Flash NPAPI

# Mount DMG
hdiutil attach /tmp/${npapidmg} -nobrowse -quiet
# Install DMG Payload (.pkg or .app)
"/Volumes/${npapivol}/Install Adobe Flash Player.app/Contents/MacOS/Adobe Flash Player Install Manager" -install
# Pause for 3 sec
sleep 3
# Unmount DMG
hdiutil detach $(df | grep "${npapivol}" | awk '{print $1}') -quiet
# Delete DMG from /tmp
rm /tmp/"${npapidmg}"

############################################################################################################################
# Install Adobe Flash PPAPI

# Mount DMG
#hdiutil attach /tmp/${ppapidmg} -nobrowse -quiet
# Install DMG Payload (.pkg or .app)
#"/Volumes/${ppapivol}/Install Adobe Pepper Flash Player.app/Contents/MacOS/Adobe Flash Player Install Manager" -install
# Pause for 3 sec
#sleep 3
# Unmount DMG
#hdiutil detach $(df | grep "${ppapivol}" | awk '{print $1}') -quiet
# Delete DMG from /tmp
#rm /tmp/"${ppapidmg}"


exit 0
