#!/bin/bash

# check that script is run as root user

if [ "$EUID" -ne 0 ]
then
    >&2 /bin/echo $'\nThis script must be run as the root user!\n'
    exit
fi

# capture user input name

while true
do
name=$(/usr/bin/osascript -e 'Tell application "System Events" to display dialog "Please enter a name for the computer using PCC naming convention or select Cancel." default answer ""' -e 'text returned of result' 2>/dev/null)
    if [ "$?" -ne 0 ]     
    then # user cancel
        exit
    elif [ -z "$name" ]
    then # loop until input or cancel
        /usr/bin/osascript -e 'Tell application "System Events" to display alert "Please enter a name or select Cancel... Thanks!" as warning'
    elif [ -n "$name" ] # user input
    then    
        break
    fi
done

# runs scutil command to make input machine name.

scutil --set LocalHostName "$name"
scutil --set ComputerName "$name"
scutil --set HostName "$name"

