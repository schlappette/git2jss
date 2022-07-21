#!/bin/bash

# This script will take an encrypted password with the salt and key pasted below. Then, it decrypts the password
# and uses it to connect to the VPN service account for 10 minutes
# To generate a new encrypted password use the following scrypt function:
# function GenerateEncryptedString() {
#     local STRING="${1}"
#     local SALT=$(openssl rand -hex 8)
#     local K=$(openssl rand -hex 12)
#     local ENCRYPTED=$(echo -n "${STRING}" | openssl enc -aes-256-cbc -a -A -S "${SALT}" -k "${K}")
#     echo "Encrypted String: ${ENCRYPTED}"
#     echo Salt: "${SALT} | Key: ${K}"
# }

# Check if VPN already connected
if ping -c 1 ad.pcc.edu &> /dev/null
then
  echo "Already connected"
else  
  # Display Popup
  dialog="Your computer is needing to connect to PCC's Network to check-in and update device policy. You can continue working but you may be asked to resync your macOS password with your current MYPCC password during the check-in process."
  description=`echo "$dialog"`
  button1="Continue"
  button2="Not Now"
  jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
  #icon="/path/to/icon"
  button=$("$jamfHelper" -windowType hud -description "$description" -button1 "$button1" -button2 "$button2" -defaultButton "1" ) # -icon "$icon"

  if [ "$button" == 2 ]; then
    echo "Not now"
    exit
  elif [ "$button" == 0 ]; then
    echo "Starting connections..."
  else
    echo "Error in popup"
  fi

  # Disconnect VPN if already connected
  /Library/Application\ Support/Checkpoint/Endpoint\ Connect/command_line disconnect

  # Decrypt the encrypted passphrase that is passed
  DECRYPTED=$(echo "${4}" | openssl enc -aes-256-cbc -d -a -A -S "4a876c16c9eb52f4" -k "26ac86723af3f32043a6f39e")
    
  # Connect to VPN service account
  /Library/Application\ Support/Checkpoint/Endpoint\ Connect/command_line connect -s "secure.pcc.edu" -u "svcVPNConnect" -p "${DECRYPTED}"  
    
  # Wait 10 minutes and then disconnect from VPN
  sleep 600 && /Library/Application\ Support/Checkpoint/Endpoint\ Connect/command_line disconnect
fi