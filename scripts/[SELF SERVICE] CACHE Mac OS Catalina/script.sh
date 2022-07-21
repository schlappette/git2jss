#!/bin/bash


#########################################################################################
#
# This Mac OS Catalina Caching script will check for the following requirements before 
# caching the installer. System must pass all requirements. Installer will be cached 
# in /Applications.
#
#
# Mac OS Catalina General Requirements:
# 	- OS X 10.9.0 or later
# 	- 20GB of available storage
#
#
# Mac Hardware Requirements and equivalent as minimum Model Identifier
# 	- MacBook (Early 2015 or newer), ie MacBook8,1
# 	- MacBook Pro (Mid 2012 or newer), ie MacBookPro9,1
# 	- MacBook Air (Mid 2012 or newer), ie MacBookAir5,1
# 	- Mac mini (Late 2012 or newer), ie Macmini6,1
# 	- iMac (Late 2012 or newer), ie iMac13,1
# 	- iMac Pro, ie iMacPro1,1
# 	- Mac Pro (Late 2013 or newer), ie MacPro6,1
#
#
#########################################################################################



#########################################################################################
############### START!                                    -- DO NOT CHANGE UNLESS NEEDED
#########################################################################################

## Caffeinate Mac
caffeinate -dis &
CAFFEINATEPID=$!

#########################################################################################
############### SYSTEM REQUIREMENTS CHECK
#########################################################################################
COMPATIBILITY="False"

OSXCHECK="Fail"
HWCHECK="Fail"
DSCHECK="Fail"

############### MINIMUM OS X ###############
## Checks minimum version of the OS (OS X 10.9 or later)
OSVERSIONMAJOR=$(sw_vers -productVersion | awk -F"." '{ print $2 }')
OSVERSIONMINOR=$(sw_vers -productVersion | awk -F"." '{ print $3 }')
## Checks if computer meets pre-requisites for Catalina
if [[ "$OSVERSIONMAJOR" -ge 9 && "$OSVERSIONMAJOR" -le 14 || "$OSVERSIONMAJOR" -eq 9 && "$OSVERSIONMINOR" -eq 0 ]]; then
	OSXCHECK="Pass"
elif [[ "$OSVERSIONMAJOR" -ge 15 ]]; then
	echo ""
    echo "Updating Jamf Inventory..."
    /usr/local/jamf/bin/jamf recon > /dev/null 2>&1;
    echo "Update Complete!"
    echo ""
  	echo "Mac is already on Mac OS Catalina. Exiting..."
	kill $CAFFEINATEPID
	exit 1
fi

############### MAC HARDWARE REQUIREMENTS ###############
## Gets the Model Identifier, splits name and major version
MODELIDENTIFIER=$(/usr/sbin/sysctl -n hw.model)
MODELNAME=$(echo "$MODELIDENTIFIER" | sed 's/[^a-zA-Z]//g')
MODELVERSION=$(echo "$MODELIDENTIFIER" | sed 's/[^0-9,]//g' | awk -F, '{print $1}')
## Checks if Model Version meets requirements
if [[ "$MODELNAME" == "MacBook" && "$MODELVERSION" -ge 8 ]]; then
		HWCHECK="Pass"
elif [[ "$MODELNAME" == "MacBookAir" && "$MODELVERSION" -ge 5 ]]; then
		HWCHECK="Pass"
elif [[ "$MODELNAME" == "MacBookPro" && "$MODELVERSION" -ge 9 ]]; then
		HWCHECK="Pass"
elif [[ "$MODELNAME" == "Macmini" && "$MODELVERSION" -ge 6 ]]; then
		HWCHECK="Pass"
elif [[ "$MODELNAME" == "iMac" && "$MODELVERSION" -ge 13 ]]; then
		HWCHECK="Pass"
elif [[ "$MODELNAME" == "iMacPro" && "$MODELVERSION" -ge 1 ]]; then
		HWCHECK="Pass"
elif [[ "$MODELNAME" == "MacPro" && "$MODELVERSION" -ge 6 ]]; then
		HWCHECK="Pass"
fi

############### DISK SPACE REQUIREMENTS ###############
## Minimum disk space required
REQUIREDMINIMUMSPACE=20
## Transform GB into Bytes
GIGABYTES=$((1024 * 1024 * 1024))
MINIMUMSPACE=$(($REQUIREDMINIMUMSPACE * $GIGABYTES))
## Gets free space on the boot drive
DISKINFOPLIST=$(/usr/sbin/diskutil info -plist /)
## 10.13.4 or later, diskutil info command output changes key from 'AvailableSpace' to 'Free Space' about disk space.
## 10.15.0 or later, diskutil info command output changes key from 'APFSContainerFree' to 'Free Space' about disk space.
FREESPACE=$(/usr/libexec/PlistBuddy -c "Print :APFSContainerFree" /dev/stdin <<< "$DISKINFOPLIST" 2>/dev/null || /usr/libexec/PlistBuddy -c "Print :FreeSpace" /dev/stdin <<< "$DISKINFOPLIST" 2>/dev/null || /usr/libexec/PlistBuddy -c "Print :AvailableSpace" /dev/stdin <<< "$DISKINFOPLIST" 2>/dev/null)
## Checks for disk space requrements
if [[ "$FREESPACE" -ge "$MINIMUMSPACE" ]]; then
	DSCHECK="Pass"
fi

############### SYSTEM CHECKER ###############
if [[ "$OSXCHECK" == "Pass" && "$HWCHECK" == "Pass" && "$DSCHECK" == "Pass" ]]; then
	echo ""
	echo "System Requirements Check Passed! "
	echo "Minimum OS X: $OSXCHECK"
	echo "Mac Hardware: $HWCHECK"
	echo "Disk Space: $DSCHECK"
    echo ""
	COMPATIBILITY="True"
else
	echo ""
	echo "System Requirements Check Failed. Exiting..."
	echo "Minimum OS X: $OSXCHECK"
	echo "Mac Hardware: $HWCHECK"
	echo "Disk Space: $DSCHECK"
	kill $CAFFEINATEPID
	exit 1
fi

#########################################################################################
############### DOWNLOAD CATALINA INSTALLER
#########################################################################################

if [[ "$COMPATIBILITY" == "True" ]]; then
#########################################################################################
	## Path to OS Installer
	OSInstaller="/Applications/Install macOS Catalina.app"
	## Mac OS Catalina Version
	installerVersion="10.15.6"

	## Check for existing OS installer
	loopCount=0
	while [ "$loopCount" -lt 3 ]; do
	    if [ -e "$OSInstaller" ]; then
        	echo ""
	        echo "$OSInstaller found, checking version."
	        currentInstallerVersion=$(/usr/libexec/PlistBuddy -c 'Print :"System Image Info":version' "$OSInstaller/Contents/SharedSupport/InstallInfo.plist")
	        echo "Mac OS installer on version $currentInstallerVersion."
	        ## Check to see if the installer version matches, or if the installer does not have InstallInfo.plist.
	        if [ "$currentInstallerVersion" = "$installerVersion" ] || [[ ! -e "$OSInstaller/Contents/SharedSupport/InstallInfo.plist" ]]; then
				/usr/local/jamf/bin/jamf recon > /dev/null 2>&1;
				echo "Mac OS installer version matches the required version. Exiting...."
				cachedInstaller=1
	        else
	            ## Delete old version. Download copy from Jamf.
	            echo "Mac OS installer found, but old. Deleting..."
	            /bin/rm -rf "$OSInstaller"
	            /bin/sleep 2
                echo "Downloading Mac OS installer from Jamf..."
                echo ""
	            /usr/local/jamf/bin/jamf policy -event download-catalina-installer;
	        fi
	        if [ "$cachedInstaller" -eq 1 ]; then
	            unsuccessfulDownload=0
	            break
	        fi
	    else
        	## Download copy from Jamf
            echo "Downloading Mac OS installer from Jamf..."
            echo ""
	        /usr/local/jamf/bin/jamf policy -event download-catalina-installer;
	    fi
	    unsuccessfulDownload=1
	    ((loopCount++))
	done

	## Unsuccessful Download Exit
	if [ "$unsuccessfulDownload" -eq 1 ]; then
	    echo "Mac OS installer download attempt failed 3 times. Exiting... "
			kill $CAFFEINATEPID
			exit 1
	fi
#########################################################################################
else
	echo "System Requirements Check Failed. Exiting..."
	echo "Minimum OS X: $OSXCHECK"
	echo "Mac Hardware: $HDCHECK"
	echo "Disk Space: $DSCHECK"
	kill $CAFFEINATEPID
	exit 1

fi

kill $CAFFEINATEPID
