#!/bin/bash

# Mount Catalina.dmg
hdiutil attach /tmp/Catalina.dmg -nobrowse

# Copy contents of Catalina.dmg to /Applications/
# Preserve all file attributes and ACLs
cp -pPR "/Volumes/Mac OS Catalina 10.15.7/Applications/Install macOS Catalina.app" /Applications/

# Identify the correct mount point for macOS_Catalina.dmg
macOS_CatalinaDMG="$(hdiutil info | grep "/Volumes/Mac OS Catalina 10.15.7" | awk '{ print $1 }')"

# Unmount the vendor supplied DMG file
hdiutil detach $macOS_CatalinaDMG

# Remove the downloaded vendor supplied DMG file
rm -f /tmp/Catalina.dmg
rm -f /tmp/Catalina.002.dmgpart
rm -f /tmp/Catalina.003.dmgpart
