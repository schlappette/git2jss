#!/bin/bash

# Jamf Extension Attribute to acquire NoMAD Pro Installation Status
# NoMAD__Installation_Status.sh



if [ -e "/Applications/NoMAD.app" ]; then
  /bin/echo "<result>True</result>"
else
  /bin/echo "<result>False</result>"
fi

exit
