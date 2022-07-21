#!/bin/bash

    
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

# Remove leftover Mcafee files & folders
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




