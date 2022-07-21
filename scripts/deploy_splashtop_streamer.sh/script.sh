#!/bin/bash
#
# STP
#
# ReleaseDate: 20200206
# Created by Cartor on 2019-06-13.
# Copyright 2019 Splashtop Inc. All rights reserved.
#

#----------------common function start-----------------------#


function setDeployCode() {
    FILENAME="${1}"

    sed "s/REPALCE_STRING/${2}/g" <<- EOF >> "${FILENAME}"
        <key>DeployCode</key>
        <string>REPALCE_STRING</string>
        <key>DeployTeamNameCache</key>
        <string></string>
        <key>DeployTeamOwnerCache</key>
        <string></string>
        <key>LastDeployCode</key>
        <string></string>
        <key>TeamCode</key>
        <string></string>
        <key>TeamCodeInUse</key>
        <string></string>
EOF
}

function setShowDeployLoginWarning() {
    FILENAME="${1}"

    ShowDeployLoginWarning="true"
    if [ "${2// }" == "0" ]; then
        ShowDeployLoginWarning="false"
    fi

    sed "s/REPALCE_STRING/${ShowDeployLoginWarning}/g" <<- EOF >> "${FILENAME}"
        <key>ShowDeployLoginWarning</key>
        <REPALCE_STRING/>
EOF
}

function setComputerName() {
    FILENAME="${1}"

    sed "s/REPALCE_STRING/${2}/g" <<- EOF >> "${FILENAME}"
        <key>HostName</key>
        <string>REPALCE_STRING</string>
EOF
}

function setPermissionProtectionOption() {
    FILENAME="${1}"
    REQUEST_PERMISSION="${2}"
    EnablePermissionProtection=""

    if [ "$REQUEST_PERMISSION" == "0" ]; then
        EnablePermissionProtection="${REQUEST_PERMISSION// }"
    fi

    if [ "$REQUEST_PERMISSION" == "1" ]; then
        EnablePermissionProtection="${REQUEST_PERMISSION// }"
    fi

    if [ "$REQUEST_PERMISSION" == "2" ]; then
        EnablePermissionProtection="${REQUEST_PERMISSION// }"
    fi

    if [ ! -z "${EnablePermissionProtection// }" ]; then
        sed "s/REPALCE_STRING/${EnablePermissionProtection}/g" <<- EOF >> "${FILENAME}"
        <key>EnablePermissionProtection</key>
        <integer>REPALCE_STRING</integer>
EOF
    fi    
}

function setSecurityOption() {
    FILENAME="${1}"
    SECURITY_OPTION="${2}"

    EnableSecurityCodeProtection=""
    EnableOSCredential=""

    if [ "$SECURITY_OPTION" == "0" ]; then
        EnableSecurityCodeProtection="false"
        EnableOSCredential="false"
    fi

    if [ "$SECURITY_OPTION" == "1" ]; then
        EnableSecurityCodeProtection="true"
        EnableOSCredential="false"
    fi

    if [ "$SECURITY_OPTION" == "2" ]; then
        EnableSecurityCodeProtection="false"
        EnableOSCredential="true"
    fi
    
    if [ ! -z "${EnableSecurityCodeProtection// }" ]; then
        sed "s/REPALCE_STRING/${EnableSecurityCodeProtection}/g" <<- EOF >> "${FILENAME}"
        <key>EnableSecurityCodeProtection</key>
        <REPALCE_STRING/>
EOF
    fi

    if [ ! -z "${EnableOSCredential// }" ]; then
        sed "s/REPALCE_STRING/${EnableOSCredential}/g" <<- EOF >> "${FILENAME}"
        <key>EnableOSCredential</key>
        <REPALCE_STRING/>
EOF
    fi    
}

function setInitSecurityCode() {
    FILENAME="${1}"

    sed "s/REPALCE_STRING/${2}/g" <<- EOF >> "${FILENAME}"
        <key>init_security_code</key>
        <string>REPALCE_STRING</string>
EOF
}

function setLegacyConnectionLoopbackOnly() {
    FILENAME="${1}"

    cat <<- EOF >> "${FILENAME}"
        <key>LegacyConnectionLoopbackOnly</key>
        <true/>
EOF
}

function setHideTrayIcon() {
    FILENAME="${1}"

    cat <<- EOF >> "${FILENAME}"
        <key>HideTrayIcon</key>
        <true/>
EOF
}

function setDefaultClientDeviceName() {
    FILENAME="${1}"

    sed "s/REPALCE_STRING/${2}/g" <<- EOF >> "${FILENAME}"
        <key>DefaultClientDeviceName</key>
        <string>REPALCE_STRING</string>
EOF
}

function setShowStreamerUI() {
    FILENAME="${1}"

    cat <<- EOF >> "${FILENAME}"
        <key>FirstTimeClose</key>
        <false/>
        <key>FirstTimeLogin</key>
        <false/>
        <key>PermissionAlert</key>
        <false/>
EOF
}

function setEnableLanConnection() {
    FILENAME="${1}"

    cat <<- EOF >> "${FILENAME}"
        <key>EnableLanConnection</key>
        <false/>
EOF
}

function setCommonDict() {
    FILENAME="${1}"
    STREAMER_TYPE="${2}"
    STREAMER="${3}"

    if [ "$STREAMER_TYPE" == "0" ]; then
        cat <<- EOF >> "${FILENAME}"
    <key>Common</key>
    <dict>
        <key>HidePreferenceDomainSelection</key>
        <true/>
        <key>EulaAccepted</key>
        <true/>
    </dict>
EOF
    else
        sed "s/REPALCE_STRING/${STREAMER_TYPE}/g" <<- EOF >> "${FILENAME}"
    <key>Common</key>
    <dict>
        <key>HidePreferenceDomainSelection</key>
        <true/>
        <key>EulaAccepted</key>
        <true/>
        <key>StreamerType</key>
        <integer>REPALCE_STRING</integer>
    </dict>
EOF
    fi
}

function setStreamerTypeDict() {
    FILENAME="${1}"
    STREAMER_TYPE="${2}"
    STREAMER="${3}"

    sed "s/REPALCE_STRING/${STREAMER}/g" <<- EOF >> "${FILENAME}"
    <key>REPALCE_STRING</key>
    <dict>
EOF

    if [ "$STREAMER_TYPE" == "0" ]; then
        cat <<- EOF >> "${FILENAME}"
        <key>ShowDeployMode</key>
        <true/>
        <key>SplashtopAccount</key>
        <string></string>
EOF
    fi

    if [ "$STREAMER_TYPE" == "1" ]; then
        cat <<- EOF >> "${FILENAME}"
        <key>ShowDeployMode</key>
        <true/>
        <key>SplashtopAccount</key>
        <string></string>
EOF
    fi

    if [ "$STREAMER_TYPE" == "2" ]; then
        cat <<- EOF >> "${FILENAME}"
        <key>FirstTimeLogin</key>
        <false/>
        <key>BackendConnected</key>
        <true/>
        <key>ClientCertificateData</key>
        <data>
        </data>
        <key>CustomizeTeamCode</key>
        <string></string>
        <key>FirstTimeLogin</key>
        <false/>
        <key>IsNewUUIDScheme</key>
        <true/>
        <key>RelayConnected</key>
        <true/>
EOF
    fi
}

function setPlistByStreamerType() {
    FILENAME="${1}"
    STREAMER_TYPE="${2}"
    STREAMER=""

    if [ "$STREAMER_TYPE" == "0" ]; then
        STREAMER="STP"
    fi

    if [ "$STREAMER_TYPE" == "1" ]; then
        STREAMER="STB"
    fi

    if [ "$STREAMER_TYPE" == "2" ]; then
        STREAMER="STE"
    fi

    cat <<- EOF > "${FILENAME}"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>UniversalSetting</key>
    <true/>
EOF

    setCommonDict "${FILENAME}" "${STREAMER_TYPE// }" "${STREAMER// }"
    setStreamerTypeDict "${FILENAME}" "${STREAMER_TYPE// }" "${STREAMER// }"
}

function setBackendAddress() {
    FILENAME="${1}"

    sed "s/REPALCE_STRING/${2}/g" <<- EOF >> "${FILENAME}"
        <key>BackendAddress</key>
        <string>REPALCE_STRING</string>
EOF
}

function setBackendAccount() {
    FILENAME="${1}"

    sed "s/REPALCE_STRING/${2}/g" <<- EOF >> "${FILENAME}"
        <key>SplashtopAccount</key>
        <string>REPALCE_STRING</string>
EOF
}

function setBackendPassword() {
    FILENAME="${1}"

    sed "s/REPALCE_STRING/${2}/g" <<- EOF >> "${FILENAME}"
        <key>SplashtopPassword</key>
        <string>REPALCE_STRING</string>
EOF
}

function restartApp() {
    APPNAME="${1}"
    ps axc -Ouser | grep -i "${APPNAME}" | awk '{print $1}' | xargs kill
    sleep 2
    open -b `osascript -e "id of app \"${APPNAME}\""`
}

#----------------common function end-------------------------#

function usage()
{
    echo -e "Usage: `basename $1` [-i input streamer dmg file] [-d deploy code] [-a account based setting] [-w show deploy warning] ..."
    echo -e "\t-i : input streamer dmg file."
    echo -e "\t-k : input streamer pkg file."
    echo -e "\t-d : deploy code."
    echo -e "\t-w : show deploy warning (0/1). (default 1)"
    echo -e "\t-n : computer name."
    echo -e "\t-s : show Streamer UI after installation (0/1). (default 1)"
    echo -e "\t-c : init security code."
    echo -e "\t-e : Require additional password to connect (0:off, 1:Require security code, 2:Require Mac login). (default 0)"
    echo -e "\t-r : Request permission to connect (0:off, 1:reject after request expires, 2:connect after request expires)."
    echo -e "\t-l : loopback connection only (0/1). (default 0)"
    echo -e "\t-v : install/update driver (0/1). (default 1)"
    echo -e "\t-h : hide tray icon (0/1). (default 0)"
    echo -e "\t-b : default client name on connection bubble."
    echo -e "\t-p : enable LAN TCP/UDP server. (default 1)"
    echo -e "\t-t : to skip install pkg or dmg, to re-cofnig settting."
}

#----------------usage function--------------------------#

CHECK_NEED_DMG_IN="0"
CHECK_NEED_DEPLOY_CODE="0"
CHECK_NEED_PKG_IN="0"
DEPLOY_CODE=""
COMPUTER_NAME=""
REQUEST_PERMISSION=""
INIT_SECURITY_CODE=""
SECURITY_OPTION=""
LOOPBACK_ONLY="0"
INSTALL_DRIVER="1"
HIDE_TRAY_ICON="0"
DEFAULT_CLIENT_NAME=""
SHOW_DEPLOY_WARNING=""
SHOW_STREAMER_UI=""
ENABLE_LAN_SERVER=""
SkippedInstall="0"

#check options
OPTIND=1
# Reset is necessary if getopts was used previously in the script.  It is a good idea to make this local in a function.
while getopts i:k:d:w:n:s:c:e:r:l:v:h:b:p:t o
do	case "$o" in
	i)
        DMG_IN="$OPTARG"
        CHECK_NEED_DMG_IN="1"
		;;
    k)
        PKG_IN="$OPTARG"
        CHECK_NEED_PKG_IN="1"
        ;;
    d)
        DEPLOY_CODE="$OPTARG"
        CHECK_NEED_DEPLOY_CODE="1"
        ;;
    w)
        SHOW_DEPLOY_WARNING="$OPTARG"
        ;;
    n)
        COMPUTER_NAME="$OPTARG"
        ;;
    s)
        SHOW_STREAMER_UI="$OPTARG"
        ;;
    c)
        INIT_SECURITY_CODE="$OPTARG"
        ;;
    e)
        SECURITY_OPTION="$OPTARG"
        ;;
    r)
        REQUEST_PERMISSION="$OPTARG"
        ;;
    l)
        LOOPBACK_ONLY="$OPTARG"
        ;;
    v)
        INSTALL_DRIVER="$OPTARG"
        ;;
    h)
        HIDE_TRAY_ICON="$OPTARG"
        ;;
    b)
        DEFAULT_CLIENT_NAME="$OPTARG"
        ;;
    p)
        ENABLE_LAN_SERVER="$OPTARG"
        ;;
    t)
        SkippedInstall="1"
        ;;
	[?])
		echo "invalid option: $1" 1>&2;
		usage "$0"
		exit 1;;
	esac
done
shift $((OPTIND-1)) # Shift off the options and optional --.

if [ "${CHECK_NEED_DMG_IN}" == "0" ] && [ "${CHECK_NEED_PKG_IN}" == "0" ] && [ "${SkippedInstall}" == "0" ]; then
    echo "Please input streamer dmg or pkg file!"
    usage "$0"
    exit 1
fi

#if [ "$CHECK_NEED_DEPLOY_CODE" == "0" ]; then
#echo "No deploy code!"
#usage "$0"
#exit 1
#fi

PRE_INSTALL_PATH="/Users/Shared/SplashtopStreamer"
#write .PreInstall
echo "Inject settings"
mkdir "$PRE_INSTALL_PATH"

if [ "$INSTALL_DRIVER" == "0" ]; then
    NO_DRIVER="${PRE_INSTALL_PATH}/.NoDriver"
    touch "$NO_DRIVER"
fi


PRE_INSTALL="${PRE_INSTALL_PATH}/.PreInstall"
FILENAME=".PreInstall.$$"
echo "Writing file ${PRE_INSTALL}"
#set plist header and common dict
# 0: STP, 1: STB, 2: STE
setPlistByStreamerType "${FILENAME}" "0"

[ ! -z "${DEPLOY_CODE// }" ] && setDeployCode "${FILENAME}" "${DEPLOY_CODE// }"
setShowDeployLoginWarning "${FILENAME}" "${SHOW_DEPLOY_WARNING// }"
[ ! -z "${COMPUTER_NAME// }" ] && setComputerName "${FILENAME}" "${COMPUTER_NAME// }"
[ ! -z "${REQUEST_PERMISSION// }" ] && setPermissionProtectionOption "${FILENAME}" "${REQUEST_PERMISSION// }"
[ ! -z "${SECURITY_OPTION// }" ] && setSecurityOption "${FILENAME}" "${SECURITY_OPTION// }"
[ ! -z "${INIT_SECURITY_CODE// }" ] && setInitSecurityCode "${FILENAME}" "${INIT_SECURITY_CODE// }"
[ "$LOOPBACK_ONLY" == "1" ] && setLegacyConnectionLoopbackOnly "${FILENAME}"
[ "$HIDE_TRAY_ICON" == "1" ] && setHideTrayIcon "${FILENAME}"
[ ! -z "${DEFAULT_CLIENT_NAME// }" ] && setDefaultClientDeviceName "${FILENAME}" "${DEFAULT_CLIENT_NAME// }"
[ "$SHOW_STREAMER_UI" == "0" ] && setShowStreamerUI "${FILENAME}"
[ "$ENABLE_LAN_SERVER" == "0" ] && setEnableLanConnection "${FILENAME}"

cat <<- EOF >> "${FILENAME}"
    </dict>
</dict>
</plist>
EOF

sudo cp -r "${FILENAME}" "${PRE_INSTALL}"
rm -rf "${FILENAME}"

if [ "${SkippedInstall}" == "0" ]; then
    if [ "$CHECK_NEED_DMG_IN" == "1" ]; then
        if [ ! -f "${DMG_IN}" ]; then
            echo "${DMG_IN} is not exist."
            rm -rf "${PRE_INSTALL}" 2>/dev/null || true
            exit 1
        fi

        #mount dmg
        VOLUME=$(hdiutil attach -nobrowse "${DMG_IN}" | awk 'END {print $3}')
        [ -z "${VOLUME}" ] && VOLUME="/Volumes/SplashtopStreamer"
        echo "Mounting dmg file, Volume ${VOLUME}."

        echo "Install silently"
        NORMAL_INSTALLER="${VOLUME}/Splashtop Streamer.pkg"
        HIDDEN_INSTALLER="${VOLUME}/.Splashtop Streamer.pkg"
        if [ -f "${NORMAL_INSTALLER}" ]; then
            sudo installer -pkg "${NORMAL_INSTALLER}" -target /
        else
            sudo installer -pkg "${HIDDEN_INSTALLER}" -target /
        fi

        echo "Unmount dmg. ${VOLUME}"
        hdiutil detach -quiet "${VOLUME}"
    else
        if [ ! -f "${PKG_IN}" ]; then
            echo "${PKG_IN} is not exist."
            rm -rf "${PRE_INSTALL}" 2>/dev/null || true
            exit 1
        fi
        sudo installer -pkg "${PKG_IN}" -target /
    fi
else
    if [ ! -e "/Applications/Splashtop Streamer.app" ]; then
        echo "Error : Splashtop Streamer is not installed."

        rm -rf "${PRE_INSTALL}" 2>/dev/null || true
        exit 1;
    fi

    echo "Skipped install pkg or dmg, to re-config setting."
    restartApp "Splashtop Streamer"
fi

#echo "Launch Streamer"
#open "/Applications/Splashtop Streamer.app"

echo "Done!"

exit 0

