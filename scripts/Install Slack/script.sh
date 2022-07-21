#!/bin/sh
# updateSlack.sh


echo 'start updateSlack.sh'

date

echo "Updating Slack"

curl -L -o /private/tmp/SlackInstaller.dmg  "https://slack.com/ssb/download-osx-universal"

#mount dmg
hdiutil mount -nobrowse "/private/tmp/SlackInstaller.dmg"
if [ $? = 0 ]; then   # if mount is successful

#remove previous version of Slack, if already installed
if [ -d /Applications/slack.app ]; then
rm -rd /Applications/slack.app
fi

#install new version
cp -r /Volumes/Slack/Slack.app /Applications
sleep 15
#Unmount
hdiutil detach /Volumes/Slack
sleep 5
    fi


#remove files
rm /private/tmp/SlackInstaller.dmg

echo 'end updateSlack.sh'
exit 0
