#!/bin/bash


# Setting Variables
dmgfile="GoogleDrive.dmg"
volname="Install Google Drive"

# Internet Path
url='https://dl.google.com/drive-file-stream/GoogleDrive.dmg'


# Remove Google Drive File Stream
# Determine if Google Drive File Stream is installed
if [ -d "/Applications/Google Drive File Stream.app" ]; then
  # Query if Google Drive File Stream is running and pipe the instance count to a value
	GoogleDriveFSProc=$(ps aux | grep -i "Google Drive File Stream.app" | wc -l)
  # Determine if there were any instances
	if [ $GoogleDriveFSProc -gt 0 ]; then
		/usr/bin/killall "Google Drive File Stream"
	fi
	# Remove the app
	rm -rd "/Applications/Google Drive File Stream.app"
fi


# Remove Google Drive Backup and Sync
if [ -d "/Applications/Backup and Sync.app" ]; then
	# Query if Google Drive is running and pipe the instance count to a value
	GoogleBackupSyncProc=$(ps aux | grep -i "Backup and Sync.app" | wc -l)
	if [ $GoogleBackupSyncProc -gt 0 ]; then
		/usr/bin/killall "Backup and Sync"
	fi
	rm -rd "/Applications/Backup and Sync.app"
fi


# Remove Google Drive (Legacy)
# Determine if Google Drive (Legacy) is installed on the system.
if [ -d "/Applications/Google Drive.app" ]; then
	# Query if Google Drive is running and pipe the instance count to a value
	GoogleDriveProc=$(ps aux | grep -i "Google Drive.app" | wc -l)
	if [ $GoogleDriveProc -gt 0 ]; then
		/usr/bin/killall "Google Drive"
	fi
	rm -rd "/Applications/Google Drive.app"
fi


# Install Google Drive File Stream
/usr/bin/curl -o /tmp/${dmgfile} ${url}
/usr/bin/hdiutil attach /tmp/${dmgfile} -nobrowse -quiet
installer -pkg "/Volumes/${volname}/GoogleDrive.pkg" -target /
/bin/sleep 10
/usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep "${volname}" | awk '{print $1}') -quiet
/bin/sleep 10
/bin/rm /tmp/"${dmgfile}"

# Resolve potential broken icon issue.
/usr/bin/touch "/Applications/Google Drive.app"

# Rename and Google Drive files
find /users/*/Google\ Drive -type d -maxdepth 0 -exec mv {} {}_old \;

# Remove Google Drive files
rm -rf /users/*/Google\ Drive_old;

exit 0

