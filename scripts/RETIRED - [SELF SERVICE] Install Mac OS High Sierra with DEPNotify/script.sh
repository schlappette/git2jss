#!/bin/bash

# Caffeinate!!!
caffeinate -dis &
caffeinatePID=$!

JAMFBIN=$(/usr/bin/which jamf)
CURRENTUSER=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

# Install DEPNotify first
$JAMFBIN policy -event depnotify_highsierra;
DNLOG=/private/tmp/DEPNotify_HighSierra/depnotify.log

# Setup DEPNotify
echo "Command: Image: /private/tmp/DEPNotify_HighSierra/highsierra_icon.png" >> $DNLOG
echo "Command: MainTitle: macOS High Sierra Upgrade" >> $DNLOG
echo "Command: MainText: Please wait while we prepare your computer for macOS High Sierra. \n \n This process will take approximately 5-10 minutes. \n \n Once completed your computer will reboot and begin the upgrade. " >> $DNLOG


# Open DEPNotify in Normal Mode
sudo -u "$CURRENTUSER" /private/tmp/DEPNotify_HighSierra/DEPNotify.app/Contents/MacOS/DEPNotify -path /private/tmp/DEPNotify_HighSierra/depnotify.log &

# Open DEPNotify in Full Screen Mode
#sudo -u "$CURRENTUSER" /private/tmp/DEPNotify_HighSierra/DEPNotify.app/Contents/MacOS/DEPNotify -fullScreen -path /private/tmp/DEPNotify_HighSierra/depnotify.log &

# Install Cached High Sierra
#echo "Status: Setting up macOS High Sierra Installer..." >> $DNLOG
#$JAMFBIN policy -event install_highsierra_cached;

# Launch macOS High Sierra Installer
echo "Status: Running macOS High Sierra Installer..." >> $DNLOG
"/Applications/Install macOS High Sierra.app/Contents/Resources/startosinstall" --agreetolicense --nointeraction --pidtosignal $caffeinatePID --rebootdelay 30;

#Reboot message
echo "Status: Rebooting..." >> $DNLOG
echo "Command: RestartNow:" >>  $DNLOG