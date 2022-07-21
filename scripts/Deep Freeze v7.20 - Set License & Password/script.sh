#!/bin/bash

dflicense="FQGH9AMD-7NJPMY9C-WP85T7R4-V8414GGW-GE3Z3DPM"
dfadmin="PCCIT"
dfpswd="jdArn0ld!"

# Set License Key
/usr/local/bin/deepfreeze license --set $dflicense ;

# Enable Password Option
/usr/local/bin/deepfreeze password enable ;

# Set Password
DFXNEWPSWD=$dfpswd /usr/local/bin/deepfreeze password add --description $dfadmin --env ;