#!/bin/bash

# Caffeinate!!!
caffeinate -dis &
caffeinatePID=$!

JAMFBIN=$(/usr/bin/which jamf)
CURRENTUSER=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

# Install DEPNotify first (set this up in your jamf server of course)
$JAMFBIN policy -event depnotify_mojave;
DNLOG=/private/tmp/DEPNotify_Mojave/depnotify.log

# Setup DEPNotify
echo "Command: Image: /private/tmp/DEPNotify_Mojave/mojave_icon.png" >> $DNLOG
echo "Command: MainTitle: macOS Mojave Upgrade" >> $DNLOG
echo "Command: MainText: Please wait while we prepare your computer for macOS Mojave. \n \n This process will take approximately 5-10 minutes. \n \n Once completed your computer will reboot and begin the upgrade. " >> $DNLOG


# Open DEPNotify
sudo -u "$CURRENTUSER" /private/tmp/DEPNotify_Mojave/DEPNotify.app/Contents/MacOS/DEPNotify -fullScreen -path /private/tmp/DEPNotify_Mojave/depnotify.log &

# Install Cached Mojave
echo "Status: Setting up macOS Mojave Installer..." >> $DNLOG
$JAMFBIN policy -event install_mojave_cached;

# Launch macOS Mojave Installer
echo "Status: Running macOS Mojave Installer..." >> $DNLOG
"/Applications/Install macOS Mojave.app/Contents/Resources/startosinstall" --agreetolicense --nointeraction --pidtosignal $caffeinatePID --rebootdelay 30;

#Reboot message
echo "Status: Rebooting..." >> $DNLOG
echo "Command: RestartNow:" >>  $DNLOG
