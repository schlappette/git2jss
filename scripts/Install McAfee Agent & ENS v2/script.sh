#!/bin/bash
# This script will Install the McAfee FrameAgent for MAC and then perform an update.

# Caffeinate!!!
caffeinate -dis &
caffeinatePID=$(echo $!)

# Define the installer file pkg name below
InstallerPKG="McAfee-Threat-Prevention-for-Mac-10.6.4-RTW-standalone-113.pkg"

# Remove conflicting software

# Uninstall Sophos if present
if [ -f "/Library/Application Support/Sophos/opm/Installer.app/Contents/MacOS/tools/InstallationDeployer" ]
  then "/Library/Application Support/Sophos/opm/Installer.app/Contents/MacOS/tools/InstallationDeployer" --remove;
fi

# Uninstall McAfee Endpoint Protection for mac if present
if [ -f "/usr/local/McAfee/uninstall" ]
  then "/usr/local/McAfee/uninstall" EPM ;
fi

# Uninstall McAfee agents if present
if [ -f "/Library/McAfee/agent/scripts/uninstall.sh" ]
  then "/Library/McAfee/agent/scripts/uninstall.sh" ;
fi

if [ -f "/Library/McAfee/cma/uninstall.sh" ]
  then "/Library/McAfee/cma/uninstall.sh" ;
fi

# Uninstall Avast! Business Security if present
if [ -f "/Library/Application Support/Avast/hub/uninstall.sh" ]
  then "/Library/Application Support/Avast/hub/uninstall.sh" ;
fi

# Remove leftover files & folders
rm -rf /usr/local/McAfee ;
rm -rf /Library/McAfee ;
rm -rf /Library/Application\ Support/McAfee ;
rm -rf /Library/LaunchAgents/com.mcafee.* ;
rm -rf /Library/LaunchDaemons/com.mcafee.* ;
rm -rf /Library/Preferences/com.mcafee.* ;
rm -rf /Library/Frameworks/VirusScanPreferences.framework ;
rm -rf /Library/Framwworks/AVEngine.framework ;
rm -rf /Library/Internet\ Plug-ins/Web\ Control.plugin ;
rm -rf /private/etc/cma.d ;
rm -rf /private/etc/cma.conf ;
rm -rf /private/etc/ma.d ;
rm -rf /private/var/McAfee ;
rm -rf /opt/McAfee ;
rm -rf /Applications/McAfee\ Endpoint\ Security\ for\ Mac.app ;

sleep 5

#Install the EPO management agent
/private/tmp/McAfee_Files/install.sh -i

# Install the Mcafee Security Product
installer -pkg /private/tmp/McAfee_Files/$InstallerPKG -allowUntrusted -target /

# Uninstall the Firewall module (not nescicary with dedicated install)
# /usr/local/McAfee/uninstall Firewall

#Uninstall the WebControl Module (not nescicary with dedicated install)
#/usr/local/McAfee/uninstall WebControl

# Collect and sent properties
"/Library/McAfee/cma/bin/cmdagent" -p

# Sleep for 30 seconds
"/bin/sleep" 30

# Check for new policies
"/Library/McAfee/cma/bin/cmdagent" -c

# Sleep for 30 seconds
"/bin/sleep" 30

# Enforce policies locally
"/Library/McAfee/cma/bin/cmdagent" -e

# Kill Caffeinate Process
kill $caffeinatePID
