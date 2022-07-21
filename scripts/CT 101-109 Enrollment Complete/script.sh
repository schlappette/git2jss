#!/usr/bin/env bash
## DEP Enrollment Complete Script.
## Runs after payload dropoff in Jamf "Enrollment Complete" policy.

JAMFBIN="/usr/local/jamf/bin/jamf"

## Disable Software Updates
echo  "disable auto updates ASAP" >> /var/log/jamf.log
/usr/sbin/softwareupdate --schedule off

## Set power management settings
echo  "set power management" >> /var/log/jamf.log
pmset -c displaysleep 60 disksleep 0 sleep 0 womp 0 ring 0 autorestart 0 halfdim 1 sms 1
pmset -b displaysleep 5 disksleep 1 sleep 10 womp 0 ring 0 autorestart 0 halfdim 1 sms 1

## Make the main script executable
echo  "setting main script permissions" >> /var/log/jamf.log
chmod a+x /var/tmp/call_provision

## Set permissions and ownership for launch daemon
echo  "set LaunchDaemon permissions" >> /var/log/jamf.log
chmod 644 /Library/LaunchDaemons/com.pccjamfdep.launch.plist
chown root:wheel /Library/LaunchDaemons/com.pccjamfdep.launch.plist

## Load launch daemon into the Launchd system
echo  "load LaunchDaemon" >> /var/log/jamf.log
launchctl load /Library/LaunchDaemons/com.pccjamfdep.launch.plist

## We have to wait for the login window to show because the machine will reboot...
## so let's start this after the setup assistant is done.
CURRENTUSER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
while [[ "$CURRENTUSER" == "_mbsetupuser" ]]; do
	sleep 5
	CURRENTUSER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
done

## APPEND MAC RENAME CSV FILE
echo "C02YQ0QAJWF1,SYCT109BX8483" >> /private/var/tmp/CT101-109_Rename.csv;

## Rename Mac from CSV file
$JAMFBIN setComputerName -fromFile /var/tmp/CT101-109_Rename.csv;

## Add PCC Setup user and set to autologin
echo "add auto-login user" >> /var/log/jamf.log
installer -pkg /private/var/tmp/PCCSetup.pkg -allowUntrusted -target / ;

## Recon
$JAMFBIN recon;

## Reboot
echo "Rebooting!" >> /var/log/jamf.log
/sbin/shutdown -r +1 &

## Wait a few seconds
sleep 5

exit 0		## Success
exit 1 ## Failure

