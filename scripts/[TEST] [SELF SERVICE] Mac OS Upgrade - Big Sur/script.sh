#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Copyright (c) 2021 Jamf.  All rights reserved.
#
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions are met:
#               * Redistributions of source code must retain the above copyright
#                 notice, this list of conditions and the following disclaimer.
#               * Redistributions in binary form must reproduce the above copyright
#                 notice, this list of conditions and the following disclaimer in the
#                 documentation and/or other materials provided with the distribution.
#               * Neither the name of the Jamf nor the names of its contributors may be
#                 used to endorse or promote products derived from this software without
#                 specific prior written permission.
#
#       THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
#       EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# This script was designed to be used in a Self Service policy to ensure specific
# requirements have been met before proceeding with an inplace upgrade of the macOS,
# as well as to address changes Apple has made to the ability to complete macOS upgrades
# silently.
#
# REQUIREMENTS:
#           - Jamf Pro
#           - macOS Clients running version 10.10.5 or later
#           - macOS Installer 10.12.4 or later
#           - eraseInstall option is ONLY supported with macOS Installer 10.13.4+ and client-side macOS 10.13+
#           - Look over the USER VARIABLES and configure as needed.
#
#
# For more information, visit https://github.com/kc9wwh/macOSUpgrade
#
# Written by: Joshua Roskos | Jamf
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# USER VARIABLES
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

## Specify path to OS installer – Use Parameter 4 in the JSS, or specify here.
## Parameter Label: Path to the macOS installer
## Example: /Applications/Install macOS High Sierra.app
OSInstaller="$( /bin/echo "$4" | /usr/bin/xargs )"

## Version of Installer OS. Use Parameter 5 in the JSS, or specify here.
## Parameter Label: Version of macOS
## Example Command: /usr/libexec/PlistBuddy -c 'Print :"System Image Info":version' "/Applications/Install macOS High Sierra.app/Contents/SharedSupport/InstallInfo.plist"
## Example: 10.12.5
installerVersion="$5"
installerVersion_Full_Integer="$( /bin/echo "$installerVersion" | /usr/bin/awk -F. '{ print ($1 * 10 ** 4 + $2 * 10 ** 2 + $3 )}' )"
installerVersion_Major_Integer=$(/bin/echo "$installerVersion" | /usr/bin/cut -d. -f 1,2 | /usr/bin/awk -F. '{for(i=1; i<=NF; i++) {printf("%02d",$i)}}')

/bin/echo "installerVersion $installerVersion"
/bin/echo "installerVersion_Full_Integer $installerVersion_Full_Integer"
/bin/echo "installerVersion_Major_Integer $installerVersion_Major_Integer"

if [ "$installerVersion_Full_Integer" -lt 110000 ]; then
    installerDMG="${OSInstaller}/Contents/SharedSupport/InstallESD.dmg"
    installerPlist="${OSInstaller}/Contents/SharedSupport/InstallInfo.plist"
else
    installerDMG="${OSInstaller}/Contents/SharedSupport/SharedSupport.dmg"
fi

## Custom Trigger used for download – Use Parameter 6 in the JSS, or specify here.
## Parameter Label: Download Policy Trigger
## This should match a custom trigger for a policy that contains just the
## MacOS installer. Make sure that the policy is scoped properly
## to relevant computers and/or users, or else the custom trigger will
## not be picked up. Use a separate policy for the script itself.
## Example trigger name: download-sierra-install
download_trigger="$( /bin/echo "$6" | /usr/bin/xargs )"

## MD5 Checksum of Installer dmg file – Use Parameter 7 in the JSS.
## Parameter Label: installESD Checksum (optional)
## This variable is OPTIONAL
## Leave the variable BLANK if you do NOT want to verify the checksum (DEFAULT)
## Example Command: /sbin/md5 /Applications/Install\ macOS\ High\ Sierra.app/Contents/SharedSupport/InstallESD.dmg
## Example MD5 Checksum: b15b9db3a90f9ae8a9df0f81741efa2b
installerDMGChecksum="$( /bin/echo "$7" | /usr/bin/xargs )"
if [ -n "$installerDMGChecksum" ]; then
    doCheckDMGchecksum=yes
else
    doCheckDMGchecksum=no
fi

## Erase & Install macOS (Factory Defaults)
## Requires macOS Installer 10.13.4 or later
## Disabled by default
## Options: 0 = Disabled / 1 = Enabled
## Use Parameter 8 in the JSS.
## Parameter Label: Upgrade or Erase (0 or 1)
eraseInstall="$8"
if [ "$eraseInstall" != "1" ]; then eraseInstall=0 ; fi
# macOS Installer 10.13.3 or ealier set 0 to it.
if [ "$installerVersion_Full_Integer" -lt 101304 ]; then
    eraseInstall=0
fi

## Enter 0 for Full Screen, 1 for Utility window (screenshots available on GitHub)
## Full Screen by default
## Use Parameter 9 in the JSS.
## Parameter Label: Full Screen or Dialog Box (0 or 1)
userDialog="$9"
if [ "$userDialog" != "1" ]; then userDialog=0 ; fi

## Enter yes to open /var/log/startosinstall.log
## Use Parameter 10 in the JSS.
## Parameter Label: Show Log File (yes or no)
ShowLogFile=$( /bin/echo "${10}" | /usr/bin/tr "[:upper:]" "[:lower:]" | /usr/bin/xargs)
if [ "$ShowLogFile" != "yes" ]; then ShowLogFile="no" ; fi

# Control for auth reboot execution.
if [ "$installerVersion_Major_Integer" -ge 1014 ]; then
    # Installer of macOS 10.14 or later set cancel to auth reboot.
    cancelFVAuthReboot=1
else
    # Installer of macOS 10.13 or earlier try to do auth reboot.
    cancelFVAuthReboot=0
fi

## Title of OS
macOSname=$(/bin/echo "$OSInstaller" | /usr/bin/sed -E 's/(.+)?Install(.+)\.app\/?/\2/' | /usr/bin/xargs)

## Title to be used for userDialog (only applies to Utility Window)
title="$macOSname Upgrade"

## Heading to be used for userDialog
heading="Please wait as we prepare your computer for $macOSname..."

## Title to be used for userDialog
description="Your computer will reboot in 5-10 minutes and begin the upgrade.
This process may take up to an hour to complete."

## Description to be used prior to downloading the OS installer
dldescription="We need to download $macOSname to your computer, this will \
take several minutes."

## Jamf Helper HUD Position if macOS Installer needs to be downloaded
## Options: ul (Upper Left); ll (Lower Left); ur (Upper Right); lr (Lower Right)
## Leave this variable empty for HUD to be centered on main screen
dlPosition="ul"

## Icon to be used for userDialog
## Default is macOS Installer logo which is included in the staged installer package
icon="$OSInstaller/Contents/Resources/InstallAssistant.icns"

## First run script to remove the installers after run installer
finishOSInstallScriptFilePath="/usr/local/jamfps/finishOSInstall.sh"

## Launch deamon settings for first run script to remove the installers after run installer
osinstallersetupdDaemonSettingsFilePath="/Library/LaunchDaemons/com.jamfps.cleanupOSInstall.plist"

## Launch agent settings for filevault authenticated reboots
osinstallersetupdAgentSettingsFilePath="/Library/LaunchAgents/com.apple.install.osinstallersetupd.plist"

## Amount of time (in seconds) to allow a user to connect to AC power before moving on
## If null or 0, then the user will not have the opportunity to connect to AC power
acPowerWaitTimer="0"

## Declare the sysRequirementErrors array
declare -a sysRequirementErrors=()

## Icon to display during the AC Power warning
warnIcon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertCautionIcon.icns"

## Icon to display when errors are found
errorIcon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns"

## The startossinstall log file path
osinstallLogfile="/var/log/startosinstall.log"

## caffeinatePID
caffeinatePID=""

## The startossinstall command option array
declare -a startosinstallOptions=()

## Determine binary name
if [ "$installerVersion_Major_Integer" -ge 1011 ]; then
 binaryNameForOSInstallerSetup="osinstallersetupd"
else
 binaryNameForOSInstallerSetup="osinstallersetupplaind"
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# FUNCTIONS
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

get_install_os_info() {
    local dmg_file tmpfile osversion info_file devfile

    dmg_file="$1"
    if [ ! -f "$dmg_file" ]; then
        /bin/echo "Not found: $dmg_file"
        exit 1
    fi
    tmpfile="$( /usr/bin/mktemp )"

    /usr/bin/hdiutil attach -mountrandom /Volumes -noverify -readonly -nobrowse "$dmg_file" > "$tmpfile"
    devfile="$( /usr/bin/awk '$NF == "GUID_partition_scheme" {print $1}' "$tmpfile" )"
    if [ -z "$devfile" ]; then
        /bin/echo "failed to mount: $dmg_file"
        /bin/rm -rf "$tmpfile"
        exit 1
    fi
    mountpoint="$( /usr/bin/awk '$2 == "Apple_HFS" {print $3}' "$tmpfile" )"
    if [ -z "$mountpoint" ]; then
        /bin/echo "something changed. failed to get mount point"
        /bin/rm -rf "$tmpfile"
        exit 1
    fi

    info_file="${mountpoint}/com_apple_MobileAsset_MacSoftwareUpdate/com_apple_MobileAsset_MacSoftwareUpdate.xml"
    osversion="$( /usr/libexec/PlistBuddy -c "print Assets:0:OSVersion" "$info_file" )"

    /bin/rm -rf "$tmpfile"
    /usr/bin/hdiutil detach "$devfile" > /dev/null 2>&1
    /bin/echo "${osversion}"
}

kill_process() {
    processPID="$1"
    if /bin/ps -p "$processPID" > /dev/null ; then
        /bin/kill "$processPID"
        wait "$processPID" 2>/dev/null
    fi
}

wait_for_ac_power() {
    local jamfHelperPowerPID
    jamfHelperPowerPID="$1"
    ## Loop for "acPowerWaitTimer" seconds until either AC Power is detected or the timer is up
    /bin/echo "Waiting for AC power..."
    while [[ "$acPowerWaitTimer" -gt "0" ]]; do
        if /usr/bin/pmset -g ps | /usr/bin/grep "AC Power" > /dev/null ; then
            /bin/echo "Power Check: OK - AC Power Detected"
            kill_process "$jamfHelperPowerPID"
            return
        fi
        /bin/sleep 1
        ((acPowerWaitTimer--))
    done
    kill_process "$jamfHelperPowerPID"
    sysRequirementErrors+=("Is connected to AC power")
    /bin/echo "Power Check: ERROR - No AC Power Detected"
}

downloadInstaller() {
    if [ ! -x /usr/local/jamf/bin/jamf ]; then
        /bin/echo "Not found: /usr/local/jamf/bin/jamf"
        return
    fi

    /bin/rm -rf "${OSInstaller:-/tmp/dummy.$$}"

    /bin/echo "Downloading macOS Installer..."
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper \
        -windowType hud \
        -windowPosition $dlPosition \
        -title "$title" \
        -alignHeading center \
        -alignDescription left \
        -description "$dldescription" \
        -lockHUD \
        -icon "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarDownloadsFolder.icns" \
        -iconSize 100 &

    ## Capture PID for Jamf Helper HUD
    jamfHUDPID=$!

    ## Run policy to cache installer
    if /usr/local/jamf/bin/jamf policy -event "$download_trigger" ; then
        jamfPolicyResult=ok
    else
        jamfPolicyResult=ng
    fi

    ## Kill Jamf Helper HUD post download
    kill_process "$jamfHUDPID"

    if [ "$jamfPolicyResult" = "ng" ]; then
        /bin/echo "Abort due to failed jamf policy -event $download_trigger"
        cleanExit 1
    fi
}

validate_power_status() {
    ## Check if device is on battery or ac power
    ## If not, and our acPowerWaitTimer is above 1, allow user to connect to power for specified time period
    if /usr/bin/pmset -g ps | /usr/bin/grep "AC Power" > /dev/null ; then
        /bin/echo "Power Check: OK - AC Power Detected"
    else
        if [[ "$acPowerWaitTimer" -gt 0 ]]; then
            /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper \
                -windowType utility \
                -title "Waiting for AC Power Connection" \
                -icon "$warnIcon" \
                -description "Please connect your computer to power using an AC power adapter. This process will continue once AC power is detected." &
            wait_for_ac_power "$!"
        else
            sysRequirementErrors+=("Is connected to AC power")
            /bin/echo "Power Check: ERROR - No AC Power Detected"
        fi
    fi
}

validate_free_space() {
    local diskInfoPlist estInstallerSizeBytes freeSpace installerPath installerVersion \
        localOSVersion noInstallerMsg requiredDiskSpaceSizeGB

    installerVersion="$1"
    installerPath="$2"
    noInstallerMsg="."
    localOSVersion="$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{ print ($1 * 10 ** 2 + $2)}')"

    diskInfoPlist=$(/usr/sbin/diskutil info -plist /)
    # 10.13.4 or later, diskutil info command output changes key from 'AvailableSpace'
    # to 'Free Space' about disk space.
    # 10.15.0 or later, diskutil info command output changes key from 'APFSContainerFree'
    # to 'Free Space' about disk space.
    freeSpace=$(
        /usr/libexec/PlistBuddy -c "Print :APFSContainerFree" /dev/stdin <<<"$diskInfoPlist" 2>/dev/null \
            || /usr/libexec/PlistBuddy -c "Print :FreeSpace" /dev/stdin <<<"$diskInfoPlist" 2>/dev/null \
            || /usr/libexec/PlistBuddy -c "Print :AvailableSpace" /dev/stdin <<<"$diskInfoPlist" 2>/dev/null
    )

    if [ "$installerVersion" -ge 1100 ]; then
        estInstallerSizeBytes=$(( 13 * 1000 ** 3 ))
        # macOS Big Sur or later (version 11.0~)
        # https://support.apple.com/HT211238
        if [ "$localOSVersion" -ge 1012 ]; then
            # Mac OS X 10.12 Sierra or later
            requiredDiskSpaceSizeGB=36
        else
            requiredDiskSpaceSizeGB=45
        fi
    elif [ "$installerVersion" -ge 1015 ]; then
        estInstallerSizeBytes=$(( 9 * 1000 ** 3 ))
        # macOS Catalina or earlier (version ~10.15)
        # https://support.apple.com/HT210222
        if [ "$localOSVersion" -le 1010 ]; then
            # Mac OS X 10.10 Yosemite or earlier
            requiredDiskSpaceSizeGB=19
        else
            requiredDiskSpaceSizeGB=13
        fi
    elif [ "$installerVersion" -ge 1014 ]; then
        estInstallerSizeBytes=$(( 7 * 1000 ** 3 ))
        # macOS Mojave or earlier (version ~10.14)
        # https://support.apple.com/kb/SP777
        requiredDiskSpaceSizeGB=13
    fi

    # The free space calculation sbutract the installer size when it is not installed yet.
    if [ ! -e "$installerPath" ]; then
        freeSpace=$((freeSpace - estInstallerSizeBytes))
        noInstallerMsg=" with the installer installed. Additinal about $(( estInstallerSizeBytes / 1000 ** 3 )) GB required."
    fi

    if [ "$freeSpace" -ge "$((requiredDiskSpaceSizeGB * 1000 ** 3))" ]; then
        /bin/echo "Disk Check: OK - $((freeSpace / 1000 ** 3)) GB Free Space Detected"
    else
        sysRequirementErrors+=("Has at least ${requiredDiskSpaceSizeGB}GB of Free Space${noInstallerMsg}")
        /bin/echo "Disk Check: ERROR - $((freeSpace / 1000 ** 3)) GB Free Space Detected. $requiredDiskSpaceSizeGB GB more free space recommended${noInstallerMsg}"
    fi
}

verifyChecksum() {
    osChecksum=$( /sbin/md5 -q "$installerDMG" )
    if [ "$osChecksum" = "$installerDMGChecksum" ]; then
        /bin/echo "Valid"
    else
        /bin/echo "not Valid"
    fi
}

cleanExit() {
    if [ -n "$caffeinatePID" ]; then
      kill_process "$caffeinatePID"
    fi
    ## Remove Script
    /bin/rm -f "$finishOSInstallScriptFilePath"
    /bin/rm -f "$osinstallersetupdDaemonSettingsFilePath"
    /bin/rm -f "$osinstallersetupdAgentSettingsFilePath"
    exit "$1"
}

check_system_requirement() {
    ## Don't waste the users time, exit here if system requirements are not met
    if [[ "${#sysRequirementErrors[@]}" -ge 1 ]]; then
        /bin/echo "Launching jamfHelper Dialog (Requirements Not Met)..."
        /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper \
            -windowType utility \
            -title "$title" -icon "$errorIcon" \
            -iconSize 100 -button1 "OK" -defaultButton 1 \
            -heading "Requirements Not Met" \
            -description "We were unable to prepare your computer for $macOSname. Please ensure your computer meets the following requirements:

$(/usr/bin/printf '\t• %s\n' "${sysRequirementErrors[@]}")

If you continue to experience this issue, please contact the PCC Service Desk at 971-722-4400."
        cleanExit 1
    fi
}

###########################################################################################
#################    ADDITIONAL FUNCTIONS ADDED BY YESHUA ERVINE    #######################

############### CHECK IF CURRENT OS VERSION IS 11.0 -- BIG SUR ###############
checkforBigSur() {
    local osVersion
    ## Pull Mac OS version
    osVersion=$(sw_vers -productVersion | awk -F"." '{ print $1 }')
    ## Checks if OS verson is on 11. Exits if TRUE.
    if [[ "$osVersion" -ge 11 ]]; then
      echo ""
      echo "Updating Jamf Inventory..."
      /usr/local/jamf/bin/jamf recon > /dev/null 2>&1;
      echo "Update Complete!"
      echo ""
      echo "Mac is already on Mac OS Big Sur. Exiting..."
      cleanExit 0
    fi
}

############### CHECK HARDWARE REQUIREMENTS FOR BIG SUR ###############
checkHardware() {
    local hwCheck modelIdentifier modelName majorVersion minorVersion
    hwCheck="Fail"
    ## Gets the Model Identifier, splits name and major version
    modelIdentifier=$(/usr/sbin/sysctl -n hw.model)
    modelName=$(echo "$modelIdentifier" | sed 's/[^a-zA-Z]//g')
    majorVersion=$(echo "$modelIdentifier" | sed 's/[^0-9,]//g' | awk -F, '{print $1}')
    minorVersion=$(echo "$modelIdentifier" | sed 's/[^0-9,]//g' | awk -F, '{print $2}')
    ## Checks if Model Version meets requirements
    if [[ "$modelName" == "MacBook" && "$majorVersion" -ge 8 ]]; then
		    hwCheck="Pass"
    elif [[ "$modelName" == "MacBookAir" && "$majorVersion" -ge 6 ]]; then
		    hwCheck="Pass"
    elif [[ "$modelName" == "MacBookPro" && "$majorVersion" -ge 11 ]]; then
		    hwCheck="Pass"
    elif [[ "$modelName" == "Macmini" && "$majorVersion" -ge 7 ]]; then
		    hwCheck="Pass"
    elif [[ "$modelName" == "iMac" && "$majorVersion" -ge 15 ]]; then
		    hwCheck="Pass"
    elif [[ "$modelName" == "iMac" && "$majorVersion" -eq 14 && "$minorVersion" -eq 4 ]]; then
  	    hwCheck="Pass"
    elif [[ "$modelName" == "iMacPro" && "$majorVersion" -ge 1 ]]; then
		    hwCheck="Pass"
    elif [[ "$modelName" == "MacPro" && "$majorVersion" -ge 6 ]]; then
		    hwCheck="Pass"
    fi

    if [[ "$hwCheck" == "Fail" ]]; then
      	echo "Mac hardware does not meet the requirements for $macOSname. Exiting..."
        echo "Hardware Model: $modelIdentifier"
        cleanExit 1
    fi
}

###########################################################################################

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# SYSTEM CHECKS
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

## If previous processes remain for some reason, the installation will freeze, so kill it.
killingProcesses=("caffeinate" "startosinstall" "$binaryNameForOSInstallerSetup")
for processName in "${killingProcesses[@]}"; do
    [ -z "$processName" ] && continue
    /bin/echo "Killing $processName processes."
    /usr/bin/killall "$processName" 2>&1 || true
done

## Caffeinate
/usr/bin/caffeinate -dis &
caffeinatePID=$!

##Get Current User
currentUser=$(/bin/echo 'show State:/Users/ConsoleUser' | /usr/sbin/scutil | /usr/bin/awk '/Name / { print $3 }')

## Check if FileVault Enabled
fvStatus=$( /usr/bin/fdesetup status | /usr/bin/head -1 )

## Run system requirement checks
checkHardware
checkforBigSur
################
validate_power_status
validate_free_space "$installerVersion_Major_Integer" "$OSInstaller"
check_system_requirement

## Check for existing OS installer
loopCount=0
unsuccessfulDownload=1
maxTrialCount=3

while [ "$loopCount" -lt "$maxTrialCount" ]; do
    if [ -d "$OSInstaller" ]; then
        if [ "$installerVersion_Full_Integer" -lt 110000 ]; then
            if [ -f "$installerPlist" ]; then
                currentInstallerVersion=$(/usr/libexec/PlistBuddy -c "print 'System Image Info:version'" "$installerPlist")
            else
                /bin/echo "Installer check: Not found $installerPlist."
            fi
        else
            currentInstallerVersion=$(get_install_os_info "$installerDMG")
        fi

        if [ -z "$currentInstallerVersion" ]; then
            ((loopCount++))
            /bin/echo "Try to download installer.app. ($loopCount / $maxTrialCount )"
            downloadInstaller
            continue
        fi

        if [ "$currentInstallerVersion" = "$installerVersion" ]; then
            /bin/echo "Installer check: Target version is ok ($currentInstallerVersion)."
        else
            ((loopCount++))
            /bin/echo "Installer check: Expected: $installerVersion Actual: $currentInstallerVersion"
            /bin/echo "Try to download installer.app. ($loopCount / $maxTrialCount )"
            downloadInstaller
            continue
        fi

        if [ "$doCheckDMGchecksum" = yes ]; then
            checkResult="$( verifyChecksum )"
            if [ "$checkResult" = "Valid" ]; then
                /bin/echo "Installer check: DMG file is $checkResult"
                unsuccessfulDownload=0
            else
                ((loopCount++))
                /bin/echo "Installer check: DMG file is $checkResult"
                /bin/echo "Try to download installer.app. ($loopCount / $maxTrialCount )"
                downloadInstaller
                continue
            fi
        else
            /bin/echo "Installer check: DMG file check: Skipped."
            unsuccessfulDownload=0
        fi

        /bin/echo "Installer check: PASSED"
        break
    else
        /bin/echo "Installer check: Not found installer.app."
        ((loopCount++))
        /bin/echo "Try to download installer.app. ($loopCount / $maxTrialCount )"
        downloadInstaller
    fi
done

if [ "$unsuccessfulDownload" -eq 1 ]; then
    /bin/echo "macOS Installer.app downloaded $maxTrialCount Times. But installer check failed."
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper \
        -windowType utility \
        -title "$title" \
        -icon "$errorIcon" \
        -iconSize 100 -button1 "OK" -defaultButton 1 \
        -heading "Error Downloading $macOSname" \
        -description "We were unable to prepare your computer for $macOSname. Please contact the PCC Service Desk at 971-722-4400."
    cleanExit 1
fi

/bin/echo "Run system requirement checks again"
validate_power_status
validate_free_space "$installerVersion_Major_Integer" "$OSInstaller"
check_system_requirement

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# CREATE FIRST BOOT SCRIPT
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

## Because the parent bash script creates a new bash script using HEREDOC ( this <<EOF >that ),
## use a backslash before the dollar sign to avoid evaluating the variable (or command) as part of creating the script.

/bin/mkdir -p /usr/local/jamfps

/bin/cat << EOF > "$finishOSInstallScriptFilePath"
#!/bin/bash
## First Run Script to remove the installer.


## Wait until /var/db/.AppleUpgrade disappears
while [ -e /var/db/.AppleUpgrade ];
do
    echo "\$(date "+%a %h %d %H:%M:%S"): Waiting for /var/db/.AppleUpgrade to disappear." >> /usr/local/jamfps/firstbootupgrade.log
    /bin/sleep 60
done

## Wait until the upgrade process completes
INSTALLER_PROGRESS_PROCESS=\$(pgrep -l "Installer Progress")
until [ "\$INSTALLER_PROGRESS_PROCESS" = "" ];
do
    echo "\$(date "+%a %h %d %H:%M:%S"): Waiting for Installer Progress to complete." >> /usr/local/jamfps/firstbootupgrade.log
    /bin/sleep 60
    INSTALLER_PROGRESS_PROCESS=\$(pgrep -l "Installer Progress")
done
## Clean up files
/bin/rm -fr "$OSInstaller"
## Update Device Inventory
/usr/local/jamf/bin/jamf recon
## Remove LaunchAgent and LaunchDaemon
/bin/rm -f "$osinstallersetupdAgentSettingsFilePath"
/bin/rm -f "$osinstallersetupdDaemonSettingsFilePath"
## Remove Script
/bin/rm -fr /usr/local/jamfps
exit 0
EOF

/usr/sbin/chown root:admin "$finishOSInstallScriptFilePath"
/bin/chmod 755 "$finishOSInstallScriptFilePath"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# LAUNCH DAEMON
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

/bin/cat << EOF > "$osinstallersetupdDaemonSettingsFilePath"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.jamfps.cleanupOSInstall</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>$finishOSInstallScriptFilePath</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

## Set the permission on the file just made.
/usr/sbin/chown root:wheel "$osinstallersetupdDaemonSettingsFilePath"
/bin/chmod 644 "$osinstallersetupdDaemonSettingsFilePath"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# LAUNCH AGENT FOR FILEVAULT AUTHENTICATED REBOOTS
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
if [ "$cancelFVAuthReboot" -eq 0 ]; then
    /bin/cat << EOP > "$osinstallersetupdAgentSettingsFilePath"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.apple.install.osinstallersetupd</string>
    <key>LimitLoadToSessionType</key>
    <string>Aqua</string>
    <key>MachServices</key>
    <dict>
        <key>com.apple.install.osinstallersetupd</key>
        <true/>
    </dict>
    <key>TimeOut</key>
    <integer>300</integer>
    <key>OnDemand</key>
    <true/>
    <key>ProgramArguments</key>
    <array>
        <string>$OSInstaller/Contents/Frameworks/OSInstallerSetup.framework/Resources/$binaryNameForOSInstallerSetup</string>
    </array>
</dict>
</plist>
EOP

    ## Set the permission on the file just made.
    /usr/sbin/chown root:wheel "$osinstallersetupdAgentSettingsFilePath"
    /bin/chmod 644 "$osinstallersetupdAgentSettingsFilePath"

fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# APPLICATION
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

## Launch jamfHelper
jamfHelperPID=""
if [ "$userDialog" -eq 0 ]; then
    /bin/echo "Launching jamfHelper as FullScreen."
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper \
        -windowType fs -title "" \
        -icon "$icon" \
        -heading "$heading" \
        -description "$description" &
    jamfHelperPID=$!
else
    /bin/echo "Launching jamfHelper as Utility Window."
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper \
        -windowType utility -title "$title" \
        -icon "$icon" \
        -heading "$heading" \
        -iconSize 100 \
        -description "$description" &
    jamfHelperPID=$!
fi

## Load LaunchAgent
if [ "$fvStatus" = "FileVault is On." ] && \
   [ "$currentUser" != "root" ] && \
   [ "$cancelFVAuthReboot" -eq 0 ] ; then
    userID=$( /usr/bin/id -u "${currentUser}" )
    /bin/launchctl bootstrap gui/"${userID}" /Library/LaunchAgents/com.apple.install.osinstallersetupd.plist
fi

## Set required startosinstall options
startosinstallOptions+=(
"--agreetolicense"
"--nointeraction"
"--pidtosignal $jamfHelperPID"
)

## Set version specific startosinstall options
if [ "$installerVersion_Major_Integer" -lt 1014 ]; then
    # This variable may have space. Therefore, escape value with duble quotation
    startosinstallOptions+=("--applicationpath \"$OSInstaller\"")
fi

if [ "$installerVersion_Major_Integer" -gt 1014 ]; then
    # The --forcequitapps option will force Self Service to quit,
    # which prevents Self Service from cancelling a restart
    startosinstallOptions+=("--forcequitapps")
fi

## Check if eraseInstall is Enabled
if [ "$eraseInstall" -eq 1 ]; then
    startosinstallOptions+=("--eraseinstall")
    /bin/echo "Script is configured for Erase and Install of macOS."
fi

## Clear and open osinstallLogfile
/bin/rm -f "${osinstallLogfile}"

## Begin Upgrade
startosinstallCommand="\"$OSInstaller/Contents/Resources/startosinstall\" ${startosinstallOptions[*]} >> $osinstallLogfile 2>&1 &"
/bin/echo "Running a command as '$startosinstallCommand'..."
eval "$startosinstallCommand"

/bin/sleep 3

if [ "$ShowLogFile" = "yes" ]; then
    launchctl asuser "$( id -u "$3" )" /usr/bin/open "${osinstallLogfile}"
fi

exit 0
