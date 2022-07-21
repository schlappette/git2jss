#!/bin/bash
#################################################
# Deep Freeze v7.30 Post Install Configuration
# Script does the following:
# - Sets Deep Freeze v7.30 license key
# - Enable password option and sets the password
#################################################

#Setting Variables
dflicense="ZVPW046T-M1HNQWNF-VACEQH5H-RXSQ1RTC-QP4FAWG7"
dfadmin="PCCIT"
dfpswd="jdArn0ld!"

###############################################################

#Enable password option
/usr/local/bin/deepfreeze password enable;

DFXNEWPSWD=$dfpswd /usr/local/bin/deepfreeze password add --description $dfadmin --env;

#Set Password
DFXPSWD=$dfpswd /usr/local/bin/deepfreeze license --set $dflicense --env || echo "Failed Licensing"
