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

#Checks and removes installed KACE Agent
if [ -f /Library/Application\ Support/Quest/KACE/bin/AMPTools ] || [ -d /Library/Application\ Support/Quest ]
then
    /Library/Application\ Support/Quest/KACE/bin/AMPTools uninstall;
	rm -rf /Library/Application\ Support/Quest/
fi

# Decrypt the encrypted passphrase that is passed
# DECRYPTED=$(echo "${4}" | openssl enc -aes-256-cbc -d -a -A -S "ca29feb9bc66d190" -k "1c9bea0111214d249f61f5be")

#Sets the host and token
/Library/Application\ Support/Quest/KACE/bin/AMPTools set HOST=pcckboxdev.pcc.edu TOKEN=TZocR0h7k09oranoX_VYCGH4hapIV9KhfP8fMf99JD-a2IbKrmN6NQ;

#Sets the host and encrypted token
#Encrypted String: U2FsdGVkX1/KKf65vGbRkKSwO5BnNVGLqnSbOqJjZWW27LNX4vHZLPUBOWBXm1r197vGjYL88sJxP/jVGfNKmRblmuwEGFmehqGznD5Vq1A=
#/Library/Application\ Support/Quest/KACE/bin/AMPTools set HOST=pcckboxdev.pcc.edu TOKEN="${DECRYPTED}";


sleep 10

# Perform an inventory update
/Library/Application\ Support/Quest/KACE/bin/runkbot 2 0;

exit 0  