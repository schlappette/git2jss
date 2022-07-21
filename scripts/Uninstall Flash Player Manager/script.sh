#!/usr/bin/env bash

# Uninstalls flash player
# Briar Schreiber 12/07/2020

if [ -d "/Applications/Utilities/Adobe Flash Player Install Manager.app" ] 
then
	echo "Uninstalling Flash"
	"/Applications/Utilities/Adobe Flash Player Install Manager.app/Contents/MacOS/Adobe Flash Player Install Manager" -uninstall
else
	echo "Flash player not installed"
fi