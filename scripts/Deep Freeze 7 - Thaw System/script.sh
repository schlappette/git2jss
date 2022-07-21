#!/usr/bin/env bash

# Get Deep Freeze version
DF7MajorVersion=$(/usr/libexec/PlistBuddy -c 'Print :"CFBundleShortVersionString"' "/Applications/Faronics/Deep Freeze Mac.app/Contents/Info.plist" | awk -F"." '{ print $2 }')

if [[ "$DF7MajorVersion" -ge 10 ]]; then
  DFXPSWD=jdArn0ld! /usr/local/bin/deepfreeze thaw --computer --env
else
  DFXPSWD=jdArn0ld! /usr/local/bin/deepfreeze thaw --startup --env
fi
