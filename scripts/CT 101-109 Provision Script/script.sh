#!/bin/bash

# Set Variables
JAMFBIN="/usr/local/jamf/bin/jamf"
setupDone="/var/db/receipts/com.pccjamfdep.provisioning.done.bom"
DNLOG=/var/tmp/depnotify.log

# If the receipt is found, DEP already ran so let's remove this script and
# the launch Daemon. This helps if someone re-enrolls a machine for some reason.
if [ -f "${setupDone}" ]; then
  # Remove the Launch Daemon
  /bin/rm -Rf /Library/LaunchDaemons/com.pccjamfdep.launch.plist
  # Remove call script
  /bin/rm -Rf /private/var/tmp/call_provision
  exit 0
fi

# Run DEP Notify after Apple Setup Assistant
SETUP_ASSISTANT_PROCESS=$(pgrep -l "Setup Assistant")
until [ "$SETUP_ASSISTANT_PROCESS" = "" ]; do
  sleep 1
  SETUP_ASSISTANT_PROCESS=$(pgrep -l "Setup Assistant")
done

# Checking to see if the Finder is running now before continuing. This can help
# in scenarios where an end user is not configuring the device.
FINDER_PROCESS=$(pgrep -l "Finder")
until [ "$FINDER_PROCESS" != "" ]; do
  sleep 1
  FINDER_PROCESS=$(pgrep -l "Finder")
done


# Get current logged in user
CURRENTUSER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

# Caffeinate Mac, this can take while.
caffeinate -dis &
caffeinatePID=$!

# Setup DEPNotify
echo "Command: Image: /var/tmp/PCC-Logo2.png" >> $DNLOG
echo "Command: MainTitle: Please wait while PCC IT prepares your device." >> $DNLOG
echo "Status: Initial Configuration Starting..." >> $DNLOG
echo "Command: DeterminateManual: 15" >> $DNLOG

# Open DEPNotify
sudo -u "$CURRENTUSER" /var/tmp/DEPNotify.app/Contents/MacOS/DEPNotify -fullScreen &

sleep 20

################################################################################
# INSTALL BASE SOFTWARE

# Chrome
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Installing Google Chrome..." >> $DNLOG
$JAMFBIN policy -event installchrome -verbose;
sleep 1

# Firefox
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Installing Mozilla Firefox..." >> $DNLOG
$JAMFBIN policy -event installfirefox -verbose;
sleep 1

# Adobe AIR
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Installing Adobe AIR..." >> $DNLOG
$JAMFBIN policy -event installadobeair -verbose;
sleep 1

# Adobe Flash
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Installing Adobe Flash..." >> $DNLOG
$JAMFBIN policy -event installadobeflash -verbose;
sleep 1

# Java
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Installing Java..." >> $DNLOG
$JAMFBIN policy -event installjava -verbose;
sleep 1

# OpenDyslexic Fonts
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Installing Open Dyslexic Fonts..." >> $DNLOG
$JAMFBIN policy -event installODF -verbose;
sleep 1

# Microsoft Office 2016
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Installing Microsoft Office 2016..." >> $DNLOG
$JAMFBIN policy -event installmsoffice -verbose;
sleep 1

# McAfee
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Installing McAfee Endpoint Security..." >> $DNLOG
$JAMFBIN policy -event installmcafee -verbose;
sleep 1

# Kace Agent 9
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Installing KACE Agent v9..." >> $DNLOG
$JAMFBIN policy -event installkace -verbose;
sleep 1
################################################################################
# INSTALL ADOBE CC 2019 CORE BUNDLE

# Adobe CC 2019 Core Bundle
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Installing Adobe CC 2019 Core Bundle..." >> $DNLOG
$JAMFBIN policy -event installadobecc2019core -verbose;
sleep 1
################################################################################
# CT 101-109 GRAPHICS DESIGN CONFIGURATION

# CT 101-109 Student Accounts
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Creating CT 101-109 Student Accounts..." >> $DNLOG
$JAMFBIN policy -event createGDaccounts -verbose;
sleep 1

# CT 101-109 Fonts
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Installing CT 101-109 Fonts..." >> $DNLOG
$JAMFBIN policy -event installGDfonts -verbose;
sleep 1

# CT 101-109 Printers
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Installing CT 101-109 Printers..." >> $DNLOG
$JAMFBIN policy -event installGDprinters -verbose;
sleep 1
################################################################################
# INSTALL DEEP FREEZE 7

# Deep Freeze 7
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Installing Deep Freeze 7..." >> $DNLOG
$JAMFBIN policy -event installGDdeepfreeze -verbose;
sleep 1
################################################################################


# Run Software updates
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Checking for and installing any OS updates..." >> $DNLOG
softwareupdate -ia;
sleep 1

# "Provision Complete" Message and Cleanup
echo "Status: Configuration Complete! Updating system inventory and restarting..." >> $DNLOG
# Create a bom file that allow this script to stop launching DEPNotify after done
touch /var/db/receipts/com.pccjamfdep.provisioning.done.bom;

# Remove Autologin PKG
rm -Rf /private/var/tmp/PCCSETUP.pkg;

# Remove Rename CSV
rm -Rf /private/var/tmp/CT101-109_Rename.csv;

# Remove autologin user password file so it doesn't login again
rm -Rf /etc/kcpassword;

# Remove the Launch Daemon
rm -Rf /Library/LaunchDaemons/com.pccjamfdep.launch.plist;

# Remove Call provision script
rm -Rf /private/var/tmp/call_provision

# Update Inventory
$JAMFBIN recon;

kill $caffeinatePID
echo "Command: RestartNow:" >>  $DNLOG

# Remove DEPNotify files and the logs
rm -Rf /var/tmp/DEPNotify.app
rm -Rf /var/tmp/PCC-Logo2.png
rm -Rf $DNLOG

