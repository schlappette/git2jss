#!/bin/bash
  
LASTPASSWORDEXPIREDDATE=$( su `/usr/bin/last -1 -t console | awk '{print $1}'` -c "defaults read com.trusourcelabs.NoMAD.plist LastPasswordExpireDate")

FORMATEDDATE=$( date -jf"%Y-%m-%d %H:%M:%S %z" "${LASTPASSWORDEXPIREDDATE}" +"%Y-%m-%d %H:%M:%S" )

echo "<result>${FORMATEDDATE}</result>"