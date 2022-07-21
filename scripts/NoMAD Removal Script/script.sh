
# /bin/bash
# Rui Qiu
# Remove NoMad and use direct AD Bind

loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk ‘{ print $3 }’`

pkill “NoMAD”
sudo rm -rf /Applications/NoMAD.app
sudo rm -rf “/Library/Managed Preferences/com.trusourcelabs.NoMAD.plist”
sudo rm -rf “/Library/Managed Preferences/$loggedInUser/com.trusourcelabs.NoMAD.plist”
sudo rm -rf “/Users/$loggedInUser/Library/LaunchAgents/com.trusourcelabs.NoMAD.plist”
sudo rm -rf ~/Library/Preferences/com.trusourcelabs.NoMAD.plist

#Refresh message information

loggedInUser=$(stat -f%Su /dev/console)
echo $loggedInUser

#message information
msgprompthead="Refresh Desktop Required"
msgrestart="This computer needs to refresh the desktop to finish uninstall of Nomad.


Please save any open files. Refresh of deskotp will occur automatically in 5 minutes.

To refresh immediately, please click Ok after closing all applications."

dialogicon="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/Resources/Message.png"
jamfhelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

restartprompt=$("${jamfhelper}" -windowType utility -heading "${msgprompthead}" -description "${msgrestart}" -icon "${dialogicon}" -button1 "Ok"  -defaultButton 1 -timeout 300)

sudo -u $loggedInUser pkill -u $loggedInUser
sudo -u $loggedInUser shutdown -r +1

exit 0