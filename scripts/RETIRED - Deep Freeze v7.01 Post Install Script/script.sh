#!/bin/bash
#################################################
# Deep Freeze 7 Post Install Configuration
# Script does the following:
# - Sets DF7 license key
# - Enable password option and sets the password
#################################################

#Setting Variables
dflicense="ETQHFFZA-YC2TCDMM-YMQSP49W-Y8RKMN04-EX0DGVYG"
dfadmin="PCCIT"
dfpswd="jdArn0ld!"

###############################################################

#Set license key
/usr/local/bin/deepfreeze license --set $dflicense;
#Enable password option
/usr/local/bin/deepfreeze password enable;
#Set password
DFXNEWPSWD=$dfpswd /usr/local/bin/deepfreeze password add --description $dfadmin --env;
