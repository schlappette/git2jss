#!/bin/bash

# Copy the settings file to the application registry folder
cp /private/tmp/vpn_configure_remote/HKLM_registry.data /Library/Application\ Support/Checkpoint/Endpoint\ Connect/registry/

# Create the new connection
yes | /Library/Application\ Support/Checkpoint/Endpoint\ Connect/command_line create -s remote.pcc.edu -a username-password

exit 0