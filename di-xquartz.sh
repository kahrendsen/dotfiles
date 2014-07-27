#!/bin/zsh -f
# Download and install (or update) Xquartz
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2014-06-10

NAME="$0:t:r"

APP_PATH='/Applications/Utilities/XQuartz.app'

	LOCAL_VERSION=`defaults read "${APP_PATH}/Contents/Info.plist" "CFBundleVersion" 2>/dev/null`

## In case you need them:
# GENERAL_URL='https://xquartz.macosforge.org/landing/'
# DOWNLOAD_URL='http://xquartz.macosforge.org/trac/wiki/Releases'

UPDATES_URL='http://xquartz.macosforge.org/downloads/sparkle/release.xml'

	REMOTE_VERSION=`curl -sL "$UPDATES_URL" | awk -F'"' '/sparkle:version=/{print $4}' | head -1`

	DOWNLOAD_ACTUAL=`curl -sL "$UPDATES_URL" | tr '"' '\012' | egrep '^http.*\.dmg' | head -1`

		FILENAME="$DOWNLOAD_ACTUAL:t"


zmodload zsh/datetime

TIME=$(strftime "%Y-%m-%d-at-%H.%M.%S" "$EPOCHSECONDS")

HOST=`hostname -s`
HOST="$HOST:l"

LOG="$HOME/Dropbox/logs/$HOST/$NAME/$TIME.txt"

[[ -d "$LOG:h" ]] || mkdir -p "$LOG:h"
[[ -e "$LOG" ]]   || touch "$LOG"

function timestamp { strftime "%Y-%m-%d at %H:%M:%S" "$EPOCHSECONDS" }
function log { 	echo "$NAME [`timestamp`]: $@" | tee -a "$LOG" }

function msg {

	MSG="$@"

	log "$MSG"

	if (( $+commands[growlnotify] ))
	then
		growlnotify --appIcon "XQuartz" --identifier "install-update-xquartz" --message "$@" --title "Install/Update XQuartz"
	fi
}

function msgs {

	MSG="$@"

	log "$MSG"

	if (( $+commands[growlnotify] ))
	then
		growlnotify --sticky --appIcon "XQuartz" --identifier "install-update-xquartz" --message "$@" --title "Install/Update XQuartz"
	fi
}


if [ "$REMOTE_VERSION" = "" ]
then
	log "REMOTE_VERSION is empty, cannot continue"
	exit 0
fi

if [ "$DOWNLOAD_ACTUAL" = "" ]
then
	log "DOWNLOAD_ACTUAL is empty, cannot continue"
	exit 0
fi	



if [ "$LOCAL_VERSION" = "$REMOTE_VERSION" ]
then
		log "$APP_PATH:t is up-to-date ($LOCAL_VERSION ~ $REMOTE_VERSION)"
		exit 0
else
			# Update Needed
		msgs "$APP_PATH:t is outdated ($LOCAL_VERSION vs $REMOTE_VERSION)"
fi

cd "$HOME/Downloads" || cd "$HOME/Desktop" || cd "$HOME" || cd /tmp

REMOTE_SIZE=`curl -sL --head "${DOWNLOAD_ACTUAL}" | awk -F' ' '/Content-Length/{print $NF}'| tr -dc '[0-9]'`

zmodload zsh/stat

function get_local_size
{

	LOCAL_SIZE=$(zstat -L +size "$FILENAME" 2>/dev/null)

}

get_local_size

while [ "$LOCAL_SIZE" -lt "$REMOTE_SIZE" ]
do

	curl -C - --max-time 3600 --fail --location --referer ";auto" --progress-bar --remote-name "${DOWNLOAD_ACTUAL}"

	get_local_size

done

MNTPNT=$(echo -n "Y" | hdid -plist "$FILENAME" 2>/dev/null | fgrep -A 1 '<key>mount-point</key>' | tail -1 | sed 's#</string>.*##g ; s#.*<string>##g')

if [ "$MNTPNT" = "" ]
then
	msgs "MNTPNT is empty"
	exit 1
fi

PKG=`find "$MNTPNT" -maxdepth 1 -iname \*.pkg`

if [ "$PKG" = "" ]
then
	msgs "PKG is empty"
	exit 1
fi

msgs "Installing $PKG (this may take awhile...)"

sudo installer -verboseR -pkg "$PKG" -target / -lang en 2>&1 | tee -a "$LOG"

EXIT="$?"

if [ "$EXIT" = "0" ]
then
	msg "Successfully installed XQuartz.app version $REMOTE_VERSION"

	COUNT='0'

	while [ -e "$MNTPNT" ]
	do
		((COUNT++))

		if [ "$COUNT" -gt "10" ]
		then
			exit 0
		fi
			# unmount the DMG
		diskutil unmount "$MNTPNT" || sleep 5
	done

	if [ ! -e "$MNTPNT" ]
	then
		msg "Unmounted $MNTPNT"
	fi

	exit 0

else
	msg "FAILED to install XQuartz.app version $REMOTE_VERSION (exit = $EXIT)"
	exit 1
fi


exit
#
#EOF
