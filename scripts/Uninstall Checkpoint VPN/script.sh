#!/bin/bash

# If the uninstaller file exists then run it
if [ -f "/Library/Application Support/Checkpoint/Endpoint Connect/uninstall" ]; then
    yes | /Library/Application\ Support/Checkpoint/Endpoint\ Connect/uninstall
fi