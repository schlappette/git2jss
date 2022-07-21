#!/bin/bash


#Function definitions
########################################################################################
remove_Office2011()
{
    echo "Stopping Office 2011 apps"
        pgrep "Microsoft Database Daemon" | xargs kill -9 2> /dev/null
        pgrep "Office365Service" | xargs kill -9 2> /dev/null
        pgrep "Microsoft AU Daemon" | xargs kill -9 2> /dev/null
        pgrep "Office365Service" | xargs kill -9 2> /dev/null
        pgrep "Communicator" | xargs kill -9 2> /dev/null
        pgrep "Microsoft Database Daemon" | xargs kill -9 2> /dev/null
        pgrep "Microsoft Lync" | xargs kill -9 2> /dev/null
        ps aux | grep "/Applications/Microsoft Office 2011" | awk '{print $2}' | xargs kill -9 2> /dev/null      #Killing the main 2011 apps (Word, PP, Excel, Outlook) by name would result in killing 2016 apps that were open at the same time since they share the exact same names, so here we kill them by file location instead.

    echo "Deleting Office 2011 folders and files"
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
}

#Put the default Mac fonts back because 2011 moves them in favor of its own.
move_fonts()
{
    echo "Move fonts back from '/Library/Fonts Disabled' to '/Library/Fonts'"
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
}

remove_2011Preferences()
{
    echo "Deleting global Office 2011 preferences"
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
        echo "Cleaning $user's Office 2011 and Lync Preferences."
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
}


#Just some housekeeping.
remove_Office2011Receipts()
{
    #Kill the package receipts for Office.
    echo "Removing all Office package receipts"
    OFFICERECEIPTS=$(pkgutil --pkgs=com.microsoft.office.*)
    for RECEIPT in $OFFICERECEIPTS
    do
        pkgutil --forget $RECEIPT
    done
}


########################################################################################
if [ -d "/Applications/Microsoft Office 2011" ]
then
    remove_Office2011
    move_fonts
    remove_2011Preferences
    #remove_2011DockIcons
    remove_Office2011Receipts
fi