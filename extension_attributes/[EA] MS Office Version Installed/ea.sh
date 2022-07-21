#!/bin/bash

wordVersion=$(defaults read "/Applications/Microsoft Word.app/Contents/Info.plist" CFBundleShortVersionString)
majorVersion=$(awk -F '.' '{print $1}' <<< "$wordVersion")
minorVersion=$(awk -F '.' '{print $2}' <<< "$wordVersion")

if [[ $majorVersion -ge "15" ]]; then
    if [[ "$majorVersion" -ge "16" ]] && [[ "$minorVersion" -ge "17" ]]; then
        echo "<result>2019</result>"
    else
        echo "<result>2016</result>"
    fi
else
    if [[ -d "/Applications/Microsoft Office 2011/" ]]; then
        echo "<result>2011</result>"
    else
        echo "<result>Not Installed</result>"
    fi
fi

exit 0