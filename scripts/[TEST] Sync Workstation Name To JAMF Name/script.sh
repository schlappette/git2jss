#!/bin/bash
# get Computer Name
computerName=$( /usr/sbin/scutil --get ComputerName )
echo "Computer Name: $computerName"

# create network name using only alphanumeric characters and hyphens for spaces
networkName=$( /usr/bin/sed -e 's/ /-/g' -e 's/[^[:alnum:]-]//g' <<< "$computerName" )
echo "Network Name: $networkName"

# set hostname and local hostname
/usr/sbin/scutil --set HostName "$networkName"
/usr/sbin/scutil --set LocalHostName "$networkName"

exit 0