#!/usr/bin/env bash

# fireeye.sh
# 
# Written by Briar Schreiber <briar.schreiber@pcc.edu>
# Last update 09/01/2021
#
# This script will remove any existing malware protection, install FireEye, and clean up.

if [ -z $4 ] || [ -z $5 ]; then
    echo "Error: missing pkg and/or config file arguments."
    exit 2
fi

# Variable Defaults Declarations
PROMPT="${11}"
DIR1="/Library/Application Support/FireEye/"
FILE1="${4}"
FILE2="${5}"
JAMFHELPER="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
TITLE="${7}"
HEADING="${8}"
DESCRIPTION="${9}"
ICON="${DIR1}${6}"
BUTTON1="Continue"
BUTTON2="Cancel"
TIMEOUT=${10}
JAMFHELPERPID=""

# Display startup warning. Pressing cancel will stop install.
function StartupNotification() {
    RESPONSE=0
    if [ "${PROMPT}" == "noprompt" ]; then
        echo "no prompt"
    elif [ "${PROMPT}" == "nocancel" ]; then
        RESPONSE=`"$JAMFHELPER" -windowType utility -title "$TITLE" -heading "$HEADING" -description "$DESCRIPTION" -icon "$ICON" -timeout $TIMEOUT -countdown -button1 "$BUTTON1" -defaultButton 1`
        echo "no cancel"
    else
        RESPONSE=`"$JAMFHELPER" -windowType utility -title "$TITLE" -heading "$HEADING" -description "$DESCRIPTION" -icon "$ICON" -timeout $TIMEOUT -countdown -button1 "$BUTTON1" -button2 "$BUTTON2" -defaultButton 1 -cancelButton 2`
    fi
    
    if [ $RESPONSE -eq 2 ]; then
        echo "Install canceled by user."
        exit 1
    fi
}

# Show a dialog while running
function ShowRunning() {
    RESPONSE=0
    if [ "${PROMPT}" == "noprompt" ]; then
        echo "no prompt"
    else
        "$JAMFHELPER" -windowType utility -title "FireEye Endpoint Security" -heading "FireEye is being installed" -description "Please do not shut down or restart your computer." -icon "$ICON" &
        export JAMFHELPERPID=$!
    fi
}

# Close JamfHelper
function CloseDialog() {
    if [ -z $JAMFHELPERPID ]; then
        kill -9 $JAMFHELPERPID
    fi
}

# Clean out all existing malware/security solutions
function RemoveExistingMalwareSolutions() {

    
    # Uninstall Sophos if present
    if [ -f "/Library/Application Support/Sophos/opm/Installer.app/Contents/MacOS/tools/InstallationDeployer" ]; then
        "/Library/Application Support/Sophos/opm/Installer.app/Contents/MacOS/tools/InstallationDeployer" --remove
    fi
    
    # Uninstall McAfee Endpoint Protection for mac if present
    if [ -f "/usr/local/McAfee/uninstall" ]; then
        "/usr/local/McAfee/uninstall" EPM
    fi
    
    # Uninstall McAfee agents if present
    if [ -f "/Library/McAfee/agent/scripts/uninstall.sh" ]; then
        "/Library/McAfee/agent/scripts/uninstall.sh"
    fi
    
    if [ -f "/Library/McAfee/cma/uninstall.sh" ]; then
        "/Library/McAfee/cma/uninstall.sh"
    fi
    
    # Uninstall Avast! Business Security if present
    if [ -f "/Library/Application Support/Avast/hub/uninstall.sh" ]; then
        "/Library/Application Support/Avast/hub/uninstall.sh"
    fi
    
    # Uninstall Malwarebytes if present
    if [ -d "/Library/Application Support/Malwarebytes" ]; then
        rm -rf "/Library/Application Support/Malwarebytes"
        rm -rf "/Library/LaunchDaemons/com.malwarebytes.EndpointAgent.plist"
    fi

    # Uninstall existing FireEye if present
    if [ -f /Library/FireEye/xagt/uninstall.tool ]; then
        /Library/FireEye/xagt/uninstall.tool
    fi
    
    # Remove leftover Mcafee files & folders
    rm -rf /usr/local/McAfee
    rm -rf /Library/McAfee
    rm -rf /Library/Application\ Support/McAfee
    rm -rf /Library/LaunchAgents/com.mcafee.*
    rm -rf /Library/LaunchDaemons/com.mcafee.*
    rm -rf /Library/Preferences/com.mcafee.*
    rm -rf /Library/Frameworks/VirusScanPreferences.framework
    rm -rf /Library/Framwworks/AVEngine.framework
    rm -rf /Library/Internet\ Plug-ins/Web\ Control.plugin
    rm -rf /private/etc/cma.d
    rm -rf /private/etc/cma.conf
    rm -rf /private/etc/ma.d
    rm -rf /private/var/McAfee
    rm -rf /opt/McAfee
    rm -rf /Applications/McAfee\ Endpoint\ Security\ for\ Mac.app


    sleep 30
    
}

# Installs FireEye
function InstallFireEye() {
    installer -pkg "$DIR1$FILE1" -target /
    sleep 15
}

# Clean up residual files
function CleanUp() {
    rm "$DIR1$FILE1"
    rm "$DIR1$FILE2"
    rm "$ICON"
    sleep 10
}

#
# MAIN
#
StartupNotification
ShowRunning
RemoveExistingMalwareSolutions
InstallFireEye
CleanUp
CloseDialog

echo "FireEye install complete!"

exit 0