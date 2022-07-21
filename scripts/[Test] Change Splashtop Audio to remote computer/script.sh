#!/bin/bash

# create Edited plist with audio enabled
sed '/EnableAudioRedirection/{n;s/.*/                <true\/>/;}' /Users/Shared/SplashtopStreamer/Splashtop-Streamer.plist > /Users/Shared/SplashtopStreamer/tmp.plist

# backup the existing plist
mv /Users/Shared/SplashtopStreamer/Splashtop-Streamer.plist /Users/Shared/SplashtopStreamer/Splashtop-Streamer.plist.bkup

# make the new config the current
cat /Users/Shared/SplashtopStreamer/tmp.plist > /Users/Shared/SplashtopStreamer/Splashtop-Streamer.plist

# close splashtop streamer
pkill -9 Splashtop\ Streamer

#reopen splashtop
open /Applications/Splashtop\ Streamer.app
