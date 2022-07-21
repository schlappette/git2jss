#!/bin/bash

TIMESTAMP=$(date +%s)
exec >/tmp/avastuninstall-"$TIMESTAMP"-$$.log 2>&1

echo "PID=$$ ID=$(id)"
set -x
shopt -s nullglob

SUPPORT_DIR="/Library/Application Support/Avast"
BASE_DIR="/Applications/Avast.app/Contents/Backend"

INSTALL_SCRIPTS_DIR="$BASE_DIR/hub"

# Setup local variables
MODULES_DIR="$INSTALL_SCRIPTS_DIR/modules"
LOCK_DIR="/tmp/com.avast.lockdir"
LOCK_CHECK_DELAY=1
SUBMIT_TOOL="$BASE_DIR/utils/com.avast.submit"

ALL_USERS=$(dscl . -list /Users)

EXIT_CODE=0
REBOOT_NECESSARY_EXIT_CODE=255



#==== FUNCTIONS ===========================

#mutual exclusion - wait for lock
#note -after reboot, the directory is always empty
acquireLock()
{
    LOCK_ACQUIRED=0
    COUNTER=0
    while [ "$LOCK_ACQUIRED" -lt 1 ]
    do
        if mkdir "$LOCK_DIR"; then
            LOCK_ACQUIRED=1
            touch "$LOCK_DIR/uninstall"
        else
            sleep "$LOCK_CHECK_DELAY"
            COUNTER=$(($COUNTER+1))
            if [ $COUNTER -eq 30 ]; then
                break
            fi
        fi
    done
}

safeExit()
{
    if [ -d "$LOCK_DIR" ]; then
        rm -rf "$LOCK_DIR"
    fi

    # If launched with com.avast.uninstall.plist, launchd will kill uninstall.sh
    (
    launchctl remove "com.avast.uninstall"
    rm -f "/Library/LaunchDaemons/com.avast.uninstall.plist"
    killall -9 "Avast"
    rm -rf "/Applications/Avast.app"
    rm -rf "${SUPPORT_DIR}"
    ) &

    exit $1
}

launchModulesRev()
{
    ARG="$1"
    printf "\n=== %s ===\n" "$ARG"
    printf "launchModulesRev start time: %s\n" $(date +%s)

    MODULES_ARR=( "$MODULES_DIR/"* )
    for (( idx=${#MODULES_ARR[@]}-1 ; idx>=0 ; idx-- )) ; do
        MOD=${MODULES_ARR[idx]}
        if [ -x "$MOD" ]; then
            printf "\n*** Module %s at %s ***\n\n" $(basename "$MOD") $(date +%s)
            "$MOD" "$ARG" 2>&1
            RET=$?
            if [ $RET != 0 ]; then
                printf "Failed: %d\n" $RET
                EXIT_CODE=$REBOOT_NECESSARY_EXIT_CODE
            fi
        fi
    done
    printf "launchModulesRev end time: %s\n" $(date +%s)
}

removeFromHomes()
{
    # dont ever delete users home 
    if [ -z "${1}" ]; then
        return
    fi

    pushd /Users

    for USERDIR in *; do
        if [ -e "/Users/${USERDIR}/${1}" ]; then
            rm -rf "/Users/${USERDIR}/${1}";
        fi
    done

    popd
}

uninstallForUser()
{
    user=$1
    user_id=$(id -u "$user")
    finder_ps_pid=$(ps -u "$user_id" -cxo comm,pid | grep -E "Finder[[:space:]]+[0-9]")
    if [ $? != 0 ]; then
        #user is not logged in
        sudo -Hu $user "${INSTALL_SCRIPTS_DIR}/userinit.sh" "stop"
        sudo -Hu $user "${INSTALL_SCRIPTS_DIR}/userinit.sh" "uninstall"
    else
        #user is logged in
        su -l $user -c "\"$INSTALL_SCRIPTS_DIR/userinit.sh\" \"stop\""
        su -l $user -c "\"$INSTALL_SCRIPTS_DIR/userinit.sh\" \"uninstall\""
    fi
}

waitUntilDone()
{
    for i in {1..30}; do
        sleep 0.5
        [ $(ps -ax | grep -vw grep | grep "$1" | wc -l) -eq 0 ] && break
    done
    [ $(ps -ax | grep -vw grep | grep "$1" | wc -l) -gt 0 ] && EXIT_CODE=$REBOOT_NECESSARY_EXIT_CODE
}

lifecycleSendEvent()
{
    if [ -x "$SUBMIT_TOOL" ]; then
        NEED_REBOOT="no"
        if [ $EXIT_CODE -ne 0 ]; then
            NEED_REBOOT="yes"
        fi

        "$SUBMIT_TOOL" -s -p lifecycle -m event "$@" -m need_reboot "$NEED_REBOOT" || echo "Warning: submit failed"
    fi
}

#==========================================

# Verify environment conditions
if [ $(id -u) -ne 0 ]; then
    echo "Script must be executed with root priviledges"
    exit 1
fi

# Stop update
launchctl unload "/Library/LaunchDaemons/com.avast.update.plist"
UPDATE_PID=$(ps -ax | grep -v "grep" | grep "$BASE_DIR/scripts/update/update.sh" | awk '{print $1}')
if [ ! -z "$UPDATE_PID" ]; then
    kill $UPDATE_PID
fi

# Uninstall per-user staff.
OLD_IFS=$IFS
IFS=$'\n'
while read -r user; do
    user_home=$(dscl . -read "/Users/$user" NFSHomeDirectory | tr -d "\n" | sed s/"NFSHomeDirectory: "//)
    if [ ! -d "${user_home}/$SUPPORT_DIR" ]; then
        continue
    fi

    uninstallForUser "$user"

    APP_TRASH_DIR="${user_home}/.Trash/Avast.app"
    [ -d "$APP_TRASH_DIR" ] && rm -r "$APP_TRASH_DIR"
done <<< "${ALL_USERS}"
IFS=$OLD_IFS

# Acuire lock
trap safeExit EXIT SIGTERM
acquireLock


# Report uninstall
if [ -f "$BASE_DIR/version.tag" ]; then
    VERSION=$(cat "$BASE_DIR/version.tag")
    lifecycleSendEvent uninstall -m from "$VERSION"
fi

# Uninstall modules
if [ -d "$MODULES_DIR" ]; then
    set +x

    # Stop system modules
    launchModulesRev "stop"

    # Uninstall system modules
    launchModulesRev "uninstall"

    set -x
else
    EXIT_CODE=$REBOOT_NECESSARY_EXIT_CODE
fi

# Store
for STORE_PRODUCT_SCRIPT in "$@"; do
    "$STORE_PRODUCT_SCRIPT" "uninstall"
done


/usr/sbin/pkgutil --forget "com.avast.avast"
/usr/sbin/pkgutil --forget "com.avast.appsupport"

# try once more just in case
/sbin/kextunload -b com.avast.PacketForwarder
/sbin/kextunload -b com.avast.FileShield

# Check that no KEXTs are loaded
if [ $(/usr/sbin/kextstat | grep com.avast | wc -l) -ne 0 ]; then
    EXIT_CODE=$REBOOT_NECESSARY_EXIT_CODE
fi

# Final cleaup of everything that needs root permissions
# Not always the modules directory is available, clean as much as possible
launchctl unload "/Library/LaunchDaemons/com.avast.init.plist"
if [ -d "$BASE_DIR" ]; then
    for plist in "$BASE_DIR/launch/LaunchDaemons/"*; do
        bname=$(basename "$plist")
        [ -f "/Library/LaunchDaemons/${bname}" ] && rm "/Library/LaunchDaemons/${bname}"
    done

    for plist in "$BASE_DIR/launch/LaunchAgents/"*; do
        bname=$(basename "$plist")
        [ -f "/Library/LaunchAgents/${bname}" ] && rm "/Library/LaunchAgents/${bname}"
    done
fi
rm -f "/Library/LaunchDaemons/com.avast.init.plist"
rm -f "/Library/LaunchDaemons/com.avast.update.plist"
rm -f "/Library/LaunchDaemons/com.avast.uninstall.plist"
rm -f "/Library/LaunchAgents/com.avast.userinit.plist"

removeFromHomes "Library/Application Support/Avast"
removeFromHomes "Library/Logs/Avast"
rm -rf "/Library/Logs/Avast"

# Release lock
exit $EXIT_CODE