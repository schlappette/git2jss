#!/bin/bash


#Checks and removes installed KACE Agent
if [ -f /Library/Application\ Support/Quest/KACE/bin/AMPTools ] || [ -d /Library/Application\ Support/Quest ]
then
    /Library/Application\ Support/Quest/KACE/bin/AMPTools uninstall;
	rm -rf /Library/Application\ Support/Quest/
fi

#Installs KACE Agent and sets server to pcckbox.pcc.edu
if [ -f "/private/tmp/jamf_payload/AMPAgent.pkg" ]
then
    sh -c 'KACE_SERVER=pcckbox.pcc.edu installer -pkg /private/tmp/jamf_payload/AMPAgent.pkg -target /';
else
    sh -c 'KACE_SERVER=pcckbox.pcc.edu installer -pkg /private/tmp/AMPAgent.pkg -target /';
fi

#Clean up
if [ -d "/private/tmp/jamf_payload" ]
then
    rm -rf /private/tmp/jamf_payload;
fi

rm -rf /private/tmp/AMPAgent.pkg;

sleep 10

/Library/Application\ Support/Quest/KACE/bin/AMPTools set HOST=pcckbox.pcc.edu

# Perform an inventory update
/Library/Application\ Support/Quest/KACE/bin/runkbot 2 0;

exit 0