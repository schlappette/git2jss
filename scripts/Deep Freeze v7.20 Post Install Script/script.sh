#!/bin/bash
#################################################
# Deep Freeze v7.20 Post Install Configuration
# Script does the following:
# - Sets Deep Freeze v7.20 license key
# - Enable password option and sets the password
#################################################

#Setting Variables
dflicense="FQGH9AMD-7NJPMY9C-WP85T7R4-V8414GGW-GE3Z3DPM"
dfadmin="PCCIT"
dfpswd="jdArn0ld!"

###############################################################

#Set license key
/usr/local/bin/deepfreeze license --set $dflicense;
#Enable password option
/usr/local/bin/deepfreeze password enable;
#Set password
DFXNEWPSWD=$dfpswd /usr/local/bin/deepfreeze password add --description $dfadmin --env;
