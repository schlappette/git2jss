#!/bin/bash
# This script will Install the McAfee FrameAgent for MAC and then perform an update.

# Define the installer file pkg name below
InstallerPKG="McAfee-Threat-Prevention-for-Mac-10.5.6-RTW-standalone-103.pkg"

# Remove conflicting software


# Uninstall Sophos if present
if [ -f "/Library/Application\ Support/Sophos/opm/Installer.app/Contents/MacOS/tools/InstallationDeployer" ]; then "/Library/Application\ Support/Sophos/opm/Installer.app/Contents/MacOS/tools/InstallationDeployer" --remove ; fi

# Uninstall McAfee Endpoint Protection for mac if present
if [ -f "/usr/local/McAfee/uninstall" ]; then "/usr/local/McAfee/uninstall" EPM ; fi

# Uninstall McAfee agents if present
if [ -f "/Library/McAfee/agent/scripts/uninstall.sh" ]; then "/Library/McAfee/agent/scripts/uninstall.sh" ; fi
if [ -f "/Library/McAfee/cma/uninst
all.sh" ]; then "/Library/McAfee/cma/uninstall.sh" ; fi

# Uninstall Avast! Business Security if present
if [ -f "/Library/Application Support/Avast/hub/uninstall.sh" ]; then "/Library/Application Support/Avast/hub/uninstall.sh" ; fi

#Instal the EPO management agent
/Library/Application\ Support/McAfee_Files/FramePKG.sh -i

# Install the Mcafee Security Product
installer -pkg /Library/Application\ Support/McAfee_Files/$InstallerPKG -allowUntrusted -target /

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

