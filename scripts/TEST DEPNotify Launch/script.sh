#!/bin/bash

# Caffeinate!!!
caffeinate -dis &
caffeinatePID=$!

JAMFBIN=$(/usr/bin/which jamf)
CURRENTUSER=$(python3 -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

# Install DEPNotify first (set this up in your jamf server of course)
#$JAMFBIN policy -event install_depnotify;
DNLOG=/var/tmp/depnotify.log

# Setup DEPNotify
echo "Command: Image: /var/tmp/PCC-Logo2.png" >> $DNLOG
echo "Command: MainTitle: Please wait while PCC IT prepares your device." >> $DNLOG
echo "Status: Installing some stuff..." >> $DNLOG
echo "Command: DeterminateManual: 13" >> $DNLOG


# Open DEPNotify
sudo -u "$CURRENTUSER" /var/tmp/DEPNotify.app/Contents/MacOS/DEPNotify -fullScreen &

echo "Status: Preparing..." >> $DNLOG
sleep 5

################################################################################
# INSTALLING BASE SOFTWARE

# Chrome
echo "Status: Installing Google Chrome..." >> $DNLOG
$JAMFBIN policy -event installchrome -verbose;
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Install complete!" >> $DNLOG
sleep 1

# Firefox
echo "Status: Installing Mozilla Firefox..." >> $DNLOG
$JAMFBIN policy -event installfirefox -verbose;
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Install complete!" >> $DNLOG
sleep 1

# Adobe Acrobat DC
echo "Status: Installing Adobe Acrobat DC..." >> $DNLOG
$JAMFBIN policy -event installacrobat -verbose;
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Install complete!" >> $DNLOG
sleep 1

# Adobe AIR
echo "Status: Installing Adobe AIR..." >> $DNLOG
$JAMFBIN policy -event installadobeair -verbose;
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Install complete!" >> $DNLOG
sleep 1

# Adobe Flash
echo "Status: Installing Adobe Flash..." >> $DNLOG
$JAMFBIN policy -event installadobeflash -verbose;
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Install complete!" >> $DNLOG
sleep 1

# Java
echo "Status: Installing Java..." >> $DNLOG
$JAMFBIN policy -event installjava -verbose;
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Install complete!" >> $DNLOG
sleep 1

# Google DFS
echo "Status: Installing Google Drive File Stream..." >> $DNLOG
$JAMFBIN policy -event installgoogledfs -verbose;
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Install complete!" >> $DNLOG
sleep 1

# VLC
echo "Status: Installing VLC Media Player..." >> $DNLOG
$JAMFBIN policy -event installvlc -verbose;
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Install complete!" >> $DNLOG
sleep 1

# OpenDyslexic Fonts
echo "Status: Installing Open Dyslexic Fonts..." >> $DNLOG
$JAMFBIN policy -event installODF -verbose;
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Install complete!" >> $DNLOG
sleep 1

# Read & Write 7
echo "Status: Installing Read & Write 7..." >> $DNLOG
$JAMFBIN policy -event installreadwrite -verbose;
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Install complete!" >> $DNLOG
sleep 1

# Microsoft Office 2016
echo "Status: Installing Microsoft Office 2016..." >> $DNLOG
$JAMFBIN policy -event installmsoffice -verbose;
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Install complete!" >> $DNLOG
sleep 1

# McAfee
echo "Status: Installing McAfee Endpoint Security..." >> $DNLOG
$JAMFBIN policy -event installmcafee -verbose;
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Install complete!" >> $DNLOG
sleep 1

# Kace Agent 9
echo "Status: Installing KACE Agent v9..." >> $DNLOG
$JAMFBIN policy -event installkace -verbose;
echo "Command: DeterminateManualStep:" >> $DNLOG
echo "Status: Install complete!" >> $DNLOG
sleep 1
################################################################################

# Update Jamf Inventory
echo "Status: Updating system inventory..." >> $DNLOG
$JAMFBIN recon;
sleep 1


# Decaffeinate
kill $caffeinatePID

# Complete Message
echo "Status: Mac Setup Complete!" >> $DNLOG
sleep 5
echo "Command: Quit" >> $DNLOG


# Remove DEPNotify files and the logs
rm -Rf /var/tmp/DEPNotify.app
rm -Rf /var/tmp/PCC-Logo2.png
rm -Rf $DNLOG
