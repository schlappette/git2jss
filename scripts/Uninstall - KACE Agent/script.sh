#!/bin/bash


#Checks and removes installed KACE Agent
if [ -f /Library/Application\ Support/Quest/KACE/bin/AMPTools ] || [ -d /Library/Application\ Support/Quest ]
then
    /Library/Application\ Support/Quest/KACE/bin/AMPTools uninstall;
	rm -rf /Library/Application\ Support/Quest/
fi

