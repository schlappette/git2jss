#!/bin/bash

# Must be run in sudo

# Removing config files in /var/tmp
  rm /var/tmp/depnotify*

# Removing bom files in /var/tmp
  rm /var/tmp/com.depnotify.*

# Removing plists in local user folder
  CURRENT_USER=$(/usr/bin/python3 -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
  rm /Users/"$CURRENT_USER"/Library/Preferences/menu.nomad.DEPNotify*

# Restarting cfprefsd due to plist changes
  killall cfprefsd

#Determine the processor brand
processorBrand=$(/usr/sbin/sysctl -n machdep.cpu.brand_string)

if [[ "${processorBrand}" = *"Apple"* ]]; then
echo "Apple Processor is present..."
else
echo "Apple Processor is not present... rosetta not needed"
exit 0
fi

#Check if the Rosetta service is running
checkRosettaStatus=$(/bin/launchctl list | /usr/bin/grep "com.apple.oahd-root-helper")

if [[ "${checkRosettaStatus}" != "" ]]; then
echo "Rosetta is installed... no action needed"
exit 0
else
echo "Rosetta is not installed... installing now"
fi

#Installs Rosetta
/usr/sbin/softwareupdate --install-rosetta --agree-to-license

#Checks the outcome of the Rosetta install
if [[ $? -eq 0 ]]; then
echo "Rosetta installed... exiting"
exit 0
else
echo "Rosetta install failed..."
exit 1
fi

exit 0
