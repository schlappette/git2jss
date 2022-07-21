#!/bin/bash

# Mount BigSur.dmg
hdiutil attach /tmp/BigSur.dmg -nobrowse

# Copy contents of BigSur.dmg to /Applications/
# Preserve all file attributes and ACLs
cp -pPR "/Volumes/Mac OS Big Sur 11.5.2/Applications/Install macOS Big Sur.app" /Applications/

# Identify the correct mount point for BigSur.dmg
macOS_BigSurDMG="$(hdiutil info | grep "/Volumes/Mac OS Big Sur 11.5.2" | awk '{ print $1 }')"

# Unmount the vendor supplied DMG file
hdiutil detach $macOS_BigSurDMG

# Remove the downloaded vendor supplied DMG file
rm -f /tmp/BigSur.dmg
rm -f /tmp/BigSur.002.dmgpart
rm -f /tmp/BigSur.003.dmgpart
rm -f /tmp/BigSur.004.dmgpart
