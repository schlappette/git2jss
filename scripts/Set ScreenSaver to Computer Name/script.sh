#!/bin/bash

currentUser=`ls -l /dev/console | awk {' print $3 '}`
su $currentUser -c "/usr/bin/defaults -currentHost write com.apple.screensaver moduleDict -dict path /System/Library/Frameworks/ScreenSaver.framework/Resources/Computer\ Name.saver"

killall cfprefsd