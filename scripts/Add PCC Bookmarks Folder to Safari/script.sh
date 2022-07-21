#!/bin/sh

over500=`dscl . list /Users UniqueID | awk '$2 > 500 { print $1 }'`

addBookmark() {
    LinkTitle=$1
    LinkURL=$2
    userName=$3
    /usr/libexec/PlistBuddy /Users/$userName/Library/Safari/Bookmarks.plist -c "Add :Children:1:Children:0 dict"
    /usr/libexec/PlistBuddy /Users/$userName/Library/Safari/Bookmarks.plist -c "Add :Children:1:Children:0:URIDictionary dict"
    /usr/libexec/PlistBuddy /Users/$userName/Library/Safari/Bookmarks.plist -c "Add :Children:1:Children:0:URIDictionary:title string ${LinkTitle}"
    /usr/libexec/PlistBuddy /Users/$userName/Library/Safari/Bookmarks.plist -c "Add :Children:1:Children:0:URLString string ${LinkURL}"
    /usr/libexec/PlistBuddy /Users/$userName/Library/Safari/Bookmarks.plist -c "Add :Children:1:Children:0:WebBookmarkType string WebBookmarkTypeLeaf"
}

createFolder() {
    folderName=$1
    userName=$2
    /usr/libexec/PlistBuddy /Users/$userName/Library/Safari/Bookmarks.plist -c "Add :Children:1 dict"
    /usr/libexec/PlistBuddy /Users/$userName/Library/Safari/Bookmarks.plist -c "Add :Children:1:Children array"
    /usr/libexec/PlistBuddy /Users/$userName/Library/Safari/Bookmarks.plist -c "Add :Children:1:WebBookmarkType string WebBookmarkTypeList"
    /usr/libexec/PlistBuddy /Users/$userName/Library/Safari/Bookmarks.plist -c "Add :Children:1:Title string ${folderName}"
}

# Run for each user
for i in $over500; do
    echo "Processing user $i"
    if [ ! "$(grep "<string>CompanyLinks</string>" /Users/$i/Library/Safari/Bookmarks.plist)" ]; then
        zip /Users/$i/Library/Safari/BookmarksBackup.zip /Users/$i/Library/Safari/Bookmarks.plist
        echo "backup of bookmarks SUCCESSFUL for the $i account."
        createFolder "Managed Bookmarks" $i
        addBookmark "Staff Directory PCC" "https://www.pcc.edu/staff/directory/" $i
        addBookmark "PCC" "https://www.pcc.edu/" $i
        addBookmark "MyPCC" "https://my.pcc.edu/" $i
        addBookmark "PCC VOIP Client" "https://voipweb.pcc.edu/client/#/logon" $i
        addBookmark "Inside PCC - Intranet" "https://intranet.pcc.edu/" $i
        addBookmark "Banner" "https://intranet.pcc.edu/banner/login/" $i
    else
        echo "User $i appears to already have the CompanyLinks bookmark folder, skipping"
    fi
done
