#!/bin/bash

dmgfile="Splashtop_Streamer_Mac_DEPLOY_INSTALLER_v3.3.8.0.dmg"
volname="SplashtopStreamer"

hdiutil attach /private/tmp/SplashtopStreamer/${dmgfile} -nobrowse -quiet

sudo /Volumes/SplashtopStreamer/Uninstall\ Splashtop\ Streamer.app/Contents/Resources/Uninstall\ Splashtop\ Streamer.sh

hdiutil detach $(/bin/df | /usr/bin/grep "${volname}" | awk '{print $1}') -quiet



