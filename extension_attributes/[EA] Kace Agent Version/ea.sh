#!/bin/sh

# Check to see if the KBox agent is installed.
# If the agent is installed, report the agent
# version.

if [ -f "/Library/Application Support/Quest/KACE/data/version" ]; then
   result=`cat "/Library/Application Support/Quest/KACE/data/version" | awk 'NR == 1'`
   echo "<result>$result</result>"
else
   echo "<result>Not Installed</result>"
fi
