#!/bin/sh
# updateZoom.sh


echo 'start updateZoom.sh'

date

echo "Updating Zoom"

curl -L -o /private/tmp/ZoomInstallerIT.pkg  "https://zoom.us/client/latest/ZoomInstallerIT.pkg"

#remove previous version of Zoom
if [ -d /Applications/zoom.us.app ]; then
rm -rd /Applications/zoom.us.app
fi

# install pkg
installer -pkg /private/tmp/ZoomInstallerIT.pkg -target /


#remove files
rm /private/tmp/ZoomInstallerIT.pkg

echo 'end updateZoom.sh'
exit 0
