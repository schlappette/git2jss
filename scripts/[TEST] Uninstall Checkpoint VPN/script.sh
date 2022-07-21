#!/bin/bash

# If the uninstaller file exists then run it
if [ -f "/Library/Application Support/Checkpoint/Endpoint Connect/uninstall" ]; then
	yes | /Library/Application\ Support/Checkpoint/Endpoint\ Connect/uninstall
fi

# Disable\enable the Wi-Fi connection if the OS is Monterey
OS_BUILD_VERSION=$(sw_Vers -buildVersion)
BIGSUR_BUILD_VERSION=20G224

if [[ "$OS_BUILD_VERSION" > "$BIGSUR_BUILD_VERSION" ]]; then
	networksetup -setnetworkserviceenabled Wi-Fi off
	sleep 5
	networksetup -setnetworkserviceenabled Wi-Fi on
	sleep 10
fi