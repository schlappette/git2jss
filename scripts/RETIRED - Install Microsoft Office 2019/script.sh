#!/bin/bash

echo "" >> /var/log/jamf.log
echo " Starting Microsoft Office 2019 Install Process" >> /var/log/jamf.log
sleep 2

#################################################################################################################

# Mac OS Version Check - Will run only on OS version 10.13.*, 10.14.*, 10.15.*. Will exit on anything older.

echo "" >> /var/log/jamf.log
echo "  Checking Mac OS version Compatibility..." >> /var/log/jamf.log

osversion=$(sw_vers | grep "ProductVersion:" | awk '{print $2}')
if [[ ${osversion} == 10.13.* ]] || [[ ${osversion} == 10.14.* ]] || [[ ${osversion} == 10.15 ]] || [[ ${osversion} == 10.15.* ]]; then

  #Caffeinate!!!
  caffeinate -dis &
  caffeinatePID=$(echo $!)
  
  echo "    -Mac OS version is compatible." >> /var/log/jamf.log

  # Set Check Values
  MSO2011="0"
  MSOffice="0"
  
  # Office Location Variables
  
  ### MS Office 2011
  Office2011="/Applications/Microsoft Office 2011/"
  
  ### MS Office 2016
  Excel="/Applications/Microsoft Excel.app"
  PowerPoint="/Applications/Microsoft PowerPoint.app"
  Word="/Applications/Microsoft Word.app"

 ##################################################################################################################

 # Check for MS Office 2011. Remove if installed.
 
  echo "" >> /var/log/jamf.log
  echo "  Checking for Microsoft Office Installs..." >> /var/log/jamf.log

  ls "$Office2011" >/dev/null 2>&1 && MSO2011="1"
  if [ "$MSO2011" == "1" ]; then
    
    echo "    -Microsoft Office 2011 Detected!" >> /var/log/jamf.log
    echo "      -Removing Microsoft Office 2011..." >> /var/log/jamf.log

    # Remove Office 2011
     # Stopping Office 2011 apps
    pgrep "Microsoft Database Daemon" | xargs kill -9 2> /dev/null
    pgrep "Office365Service" | xargs kill -9 2> /dev/null
    pgrep "Microsoft AU Daemon" | xargs kill -9 2> /dev/null
    pgrep "Office365Service" | xargs kill -9 2> /dev/null
    pgrep "Communicator" | xargs kill -9 2> /dev/null
    pgrep "Microsoft Database Daemon" | xargs kill -9 2> /dev/null
    pgrep "Microsoft Lync" | xargs kill -9 2> /dev/null
    ps aux | grep "/Applications/Microsoft Office 2011" | awk '{print $2}' | xargs kill -9 2> /dev/null      #Killing the main 2011 apps (Word, PP, Excel, Outlook) by name would result in killing 2016 apps that were open at the same time since they share the exact same names, so here we kill them by file location instead.

     # Deleting Office 2011 folders and files
    rm -rf '/Applications/Microsoft Communicator.app/'
    rm -rf '/Applications/Microsoft Messenger.app/'
    rm -rf '/Applications/Microsoft Lync.app/'
    rm -rf '/Applications/Microsoft Office 2011/'
    rm -rf '/Applications/Remote Desktop Connection.app/'
    rm -rf '/Library/Application Support/Microsoft/Communicator'
    rm -rf '/Library/Application Support/Microsoft/MERP2.0'
    rm -rf /Library/Automator/*Excel*
    rm -rf /Library/Automator/*Office*
    rm -rf /Library/Automator/*Outlook*
    rm -rf /Library/Automator/*PowerPoint*
    rm -rf /Library/Automator/*Word*
    rm -rf /Library/Automator/*Workbook*
    rm -rf '/Library/Automator/Get Parent Presentations of Slides.action'
    rm -rf '/Library/Automator/Set Document Settings.action'
    rm -rf /Library/Fonts/Microsoft/
    rm -rf /Library/Internet\ Plug-Ins/SharePoint*
    rm -rf /Library/LaunchDaemons/com.microsoft.office.licensing.helper.plist
    rm -rf /Library/PrivilegedHelperTools/com.microsoft.office.licensing.helper

    #Put the default Mac fonts back because 2011 moves them in favor of its own.
     # Move fonts back from '/Library/Fonts Disabled' to '/Library/Fonts'
    mv '/Library/Fonts Disabled/Arial Bold Italic.ttf' /Library/Fonts
    mv '/Library/Fonts Disabled/Arial Bold.ttf' /Library/Fonts
    mv '/Library/Fonts Disabled/Arial Italic.ttf' /Library/Fonts
    mv '/Library/Fonts Disabled/Arial.ttf' /Library/Fonts
    mv '/Library/Fonts Disabled/Brush Script.ttf' /Library/Fonts
    mv '/Library/Fonts Disabled/Times New Roman Bold Italic.ttf' /Library/Fonts
    mv '/Library/Fonts Disabled/Times New Roman Bold.ttf' /Library/Fonts
    mv '/Library/Fonts Disabled/Times New Roman Italic.ttf' /Library/Fonts
    mv '/Library/Fonts Disabled/Times New Roman.ttf' /Library/Fonts
    mv '/Library/Fonts Disabled/Verdana Bold Italic.ttf' /Library/Fonts
    mv '/Library/Fonts Disabled/Verdana Bold.ttf' /Library/Fonts
    mv '/Library/Fonts Disabled/Verdana Italic.ttf' /Library/Fonts
    mv '/Library/Fonts Disabled/Verdana.ttf' /Library/Fonts
    mv '/Library/Fonts Disabled/Wingdings 2.ttf' /Library/Fonts
    mv '/Library/Fonts Disabled/Wingdings 3.ttf' /Library/Fonts
    mv '/Library/Fonts Disabled/Wingdings.ttf' /Library/Fonts

     # echo "Deleting global Office 2011 preferences"
    rm -rf "/Library/Preferences/com.microsoft.Word.plist"
    rm -rf "/Library/Preferences/com.microsoft.Excel.plist"
    rm -rf "/Library/Preferences/com.microsoft.Powerpoint.plist"
    rm -rf "/Library/Preferences/com.microsoft.Outlook.plist"
    rm -rf "/Library/Preferences/com.microsoft.outlook.databasedaemon.plist"
    rm -rf "/Library/Preferences/com.microsoft.DocumentConnection.plist"
    rm -rf "/Library/Preferences/com.microsoft.office.setupassistant.plist"

    # Loop through each user to kill Office 2011 Preferences and some misc folders.
    for user in $(ls /Users | grep -v Shared | grep -v npsparcc | grep -v ".localized"); #Set $user to the results of listing /Users, excluding "Shared" and "npsparcc"
    do
      # echo "Cleaning $user's Office 2011 and Lync Preferences."
      rm -rf "/Users/$user/Library/Preferences/com.microsoft.Word.plist"
      rm -rf "/Users/$user/Library/Preferences/com.microsoft.Excel.plist"
      rm -rf "/Users/$user/Library/Preferences/com.microsoft.Powerpoint.plist"
      rm -rf "/Users/$user/Library/Preferences/com.microsoft.Outlook.plist"
      rm -rf "/Users/$user/Library/Preferences/com.microsoft.outlook.databasedaemon.plist"
      rm -rf "/Users/$user/Library/Preferences/com.microsoft.outlook.office_reminders.plist"
      rm -rf "/Users/$user/Library/Preferences/com.microsoft.DocumentConnection.plist"
      rm -rf "/Users/$user/Library/Preferences/com.microsoft.office.setupassistant.plist"
      rm -rf "/Users/$user/Library/Preferences/com.microsoft.office.plist"
      rm -rf "/Users/$user/Library/Preferences/com.microsoft.error_reporting.plist"
      rm -rf "/Users/$user/Library/Preferences/ByHost/com.microsoft.Word.*.plist"
      rm -rf "/Users/$user/Library/Preferences/ByHost/com.microsoft.Excel.*.plist"
      rm -rf "/Users/$user/Library/Preferences/ByHost/com.microsoft.Powerpoint.*.plist"
      rm -rf "/Users/$user/Library/Preferences/ByHost/com.microsoft.Outlook.*.plist"
      rm -rf "/Users/$user/Library/Preferences/ByHost/com.microsoft.outlook.databasedaemon.*.plist"
      rm -rf "/Users/$user/Library/Preferences/ByHost/com.microsoft.DocumentConnection.*.plist"
      rm -rf "/Users/$user/Library/Preferences/ByHost/com.microsoft.office.setupassistant.*.plist"
      rm -rf "/Users/$user/Library/Preferences/ByHost/com.microsoft.registrationDB.*.plist"
      rm -rf "/Users/$user/Library/Preferences/ByHost/com.microsoft.e0Q*.*.plist"
      rm -rf "/Users/$user/Library/Preferences/ByHost/com.microsoft.Office365.*.plist"
      rm -rf "/Users/$user/Library/Caches/com.microsoft.browseRont.cache"
      rm -rf "/Users/$user/Library/Caches/com.microsoft.office.setupassistant"
      rm -rf "/Users/$user/Library/Caches/Microsoft/Office"
      rm -rf "/Users/$user/Library/Caches/Outlook"
      rm -rf "/Users/$user/Library/Caches/com.microsoft.Outlook"
      rm -rf "/Users/$user/Library/Application Support/Microsoft/Office"
      rm -rf /Users/$user/Library/Application\ Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.microsoft.lync.sfl
      rm -rf /Users/$user/Library/Cookies/com.microsoft.Lync.binarycookies
      rm -rf /Users/$user/Library/Caches/com.microsoft.Lync
      rm -rf /Users/$user/Library/Group\ Containers/UBF8T346G9.Office/Lync
      rm -rf /Users/$user/Library/Logs/Microsoft-Lync*
      rm -rf /Users/$user/Library/Preferences/ByHost/MicrosoftLync*
      rm -rf /Users/$user/Library/Preferences/com.microsoft.Lync.plist
      rm -rf /Users/$user/Library/Receipts/Lync.Client.Plugin.plist
      rm -rf /Users/$user/Library/Keychains/OC_KeyContainer*
      rm -rf /Users/$user/Documents/Microsoft\ User\ Data/Microsoft\ Lync\ Data
      rm -rf /Users/$user/Documents/Microsoft\ User\ Data/Microsoft/Communicator
    done

    #Kill the package receipts for Office.
    # echo "Removing all Office package receipts"
    OFFICERECEIPTS=$(pkgutil --pkgs=com.microsoft.office.*)
    for RECEIPT in $OFFICERECEIPTS
    do
      pkgutil --forget $RECEIPT
    done
    echo "      -Microsoft Office 2011 removal complete!" >> /var/log/jamf.log
  fi

  #################################################################################################################
  #Check for MS Office 2016 or 2019. Remove if installed.
  
 # ls "$Excel" "$PowerPoint" "$Word" >/dev/null 2>&1 && MSOffice="1"
  
 # if [ "$MSOffice" == "1" ]; then
 #   MSOver=""
 #   MSwordVersion="$(defaults read /Applications/Microsoft\ Word.app/Contents/Info CFBundleShortVersionString)"
 #   reqVersion="16.17.0"
 #   if [ "$(printf '%s\n' "$reqVersion" "$MSwordVersion" | sort -V | head -n1)" = "$reqVersion" ]; then
 #     MSOver="2019"
 #     echo "    -Microsoft Office 2019 detected!" >> /var/log/jamf.log
 #     echo "      -Removing Microsoft Office 2019..." >> /var/log/jamf.log
 #   else
 #     MSOver="2016"
 #     echo "    -Microsoft Office 2016 detected!" >> /var/log/jamf.log
 #     echo "      -Removing Microsoft Office 2016..." >> /var/log/jamf.log
 #   fi

    # Remove Office 2016/2019
 #   consoleuser=$(ls -l /dev/console | awk '{ print $3 }')
 #   pkill -f Microsoft

 #   folders=(
 #   "/Applications/Microsoft Excel.app"
 #   "/Applications/Microsoft OneNote.app"
 #   "/Applications/Microsoft Outlook.app"
 #   "/Applications/Microsoft PowerPoint.app"
 #   "/Applications/Microsoft Word.app"
 #   "/Library/Application\ Support/Microsoft/"
    #
 #   "/Users/$consoleuser/Library/Application\ Support/Microsoft AU Daemon"
 #   "/Users/$consoleuser/Library/Application Support/Microsoft AutoUpdate"
 #   "/Users/$consoleuser/Library/Preferences/com.microsoft.autoupdate.fba.debuglogging.plist"
 #   "/Users/$consoleuser/Library/Preferences/com.microsoft.autoupdate.fba.plist"
 #   "/Users/$consoleuser/Library/Preferences/com.microsoft.autoupdate2.plist"
 #   "/Users/$consoleuser/Library/Containers/com.microsoft.errorreporting"
 #   "/Users/$consoleuser/Library/Containers/com.microsoft.Excel"
 #   "/Users/$consoleuser/Library/Containers/com.microsoft.netlib.shipassertprocess"
 #   "/Users/$consoleuser/Library/Containers/com.microsoft.Office365ServiceV2"
 #   "/Users/$consoleuser/Library/Containers/com.microsoft.Outlook"
 #   "/Users/$consoleuser/Library/Containers/com.microsoft.Powerpoint"
 #   "/Users/$consoleuser/Library/Containers/com.microsoft.RMS-XPCService"
 #   "/Users/$consoleuser/Library/Containers/com.microsoft.Word"
 #   "/Users/$consoleuser/Library/Containers/com.microsoft.onenote.mac"
    #
    #### WARNING: Outlook data will be removed when you move the three folders listed below.
    #### You should back up these folders before you delete them.
  #  "/Users/$consoleuser/Library/Group Containers/UBF8T346G9.ms"
  #  "/Users/$consoleuser/Library/Group Containers/UBF8T346G9.Office"
  #  "/Users/$consoleuser/Library/Group Containers/UBF8T346G9.OfficeOsfWebHost"
  #  "/Users/$consoleuser/Library/Group Containers/UBF8T346G9.OfficeOneDriveSyncIntegration"
   # )

  #  search="*"

  #  for i in "${folders[@]}"
  #  do
  #    rm -rf "${i}"
  #  done
  #  echo "      -Microsoft Office $MSOver removal complete!" >> /var/log/jamf.log
  #fi

  #################################################################################################################

  # DOWNLOAD & INSTALL MICROSOFT OFFICE 2019 PKG
  
  echo "" >> /var/log/jamf.log
  
  echo "  Downloading Microsoft Office 2019..." >> /var/log/jamf.log
  curl -L -o /tmp/Microsoft_Office_2019_Installer.pkg https://go.microsoft.com/fwlink/?linkid=525133;
  if [ $? -ne 0 ]; then echo "   -Unable to download Microsoft Office 2019 pkg. Possible network connection loss. Flush the system from the policy logs and try again." >> /var/log/jamf.log; kill $caffeinatePID; exit 1; fi
  echo "    -Download Complete!" >> /var/log/jamf.log
  
  echo "" >> /var/log/jamf.log
  
  echo "  Installing Microsoft Office 2019..." >> /var/log/jamf.log
  installer -pkg /tmp/Microsoft_Office_2019_Installer.pkg -target /;
  if [ $? -ne 0 ]; then echo "   -Microsoft Office 2019 pkg installer failed. Flush the system from the policy logs and try again." >> /var/log/jamf.log; kill $caffeinatePID; exit 1; fi
  echo "    -Microsoft Office 2019 Installed!" >> /var/log/jamf.log
  
  echo "" >> /var/log/jamf.log
  
  echo "  Serializing Microsoft Office 2019..." >> /var/log/jamf.log
  jamf policy -event office2019_vlserialize;
  if [ $? -ne 0 ]; then echo "   -Failed to serialize Microsoft Office 2019. Run the Serialize Office 2019 policy in JAMF Pro to remediate the issue. If the issue persists, Contact your campus JDA member." >> /var/log/jamf.log; fi
  echo "    -Microsoft Office 2019 Serialized!" >> /var/log/jamf.log
  
  echo "" >> /var/log/jamf.log
  
  echo "  Updating Jamf Inventory..." >> /var/log/jamf.log
  jamf recon;
  echo "    -Jamf Inventory Updated!" >> /var/log/jamf.log
  
  echo "" >> /var/log/jamf.log
  
  echo " Microsoft Office 2019 Install Process Complete! Exiting..." >> /var/log/jamf.log
  
  echo "" >> /var/log/jamf.log
  
  kill $caffeinatePID
  exit 0

else
  echo "" >> /var/log/jamf.log
  echo "    -Mac OS version not compatible." >> /var/log/jamf.log
  echo "    -Mac OS must be at version 10.13.0 or later for installer to continue." >> /var/log/jamf.log
  echo "    -Exiting..." >> /var/log/jamf.log
  echo "" >> /var/log/jamf.log
  exit 1
fi
