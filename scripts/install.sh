#!/bin/bash

ME="$0"

ZIMBRA_USER="zimbra"
ZIMBRA_GROUP="zimbra"

ZIMBRA_DIRS="
    /var/lib/dpkg
    /var/lib/dpkg/updates
    /var/lib/dpkg/triggers
    /var/log/
    /.tmp
    /bin
    /lib/jars
    /zimlets-install
    /packages
    /services
"

ZIMBRA_FILES="
    /var/lib/dpkg/status
    /var/lib/dpkg/available
"

MY_COMMANDS="
    bin/zmpkg
    bin/zm_check_jsp
    bin/zm_redmine_upload
"

err() {
	echo "$ME: $*" >&2
	exit 1
}

zmpkg_help() {
	echo "$ME <zimbra-root>" >&2
	exit 1
}

dpkg_init() {
	for i in $ZIMBRA_DIRS ; do
		mkdir -p $ZIMBRA_HOME/$i
		chown $ZIMBRA_USER:$ZIMBRA_GROUP $ZIMBRA_HOME/$i
	done

	for i in $ZIMBRA_FILES ; do
		touch $ZIMBRA_HOME/$i
		chown $ZIMBRA_USER:$ZIMBRA_GROUP $ZIMBRA_HOME/$i
	done

	for i in $MY_COMMANDS ; do
		if [ -f $ZIMBRA_HOME/$i ]; then
			chown $ZIMBRA_USER:$ZIMBRA_GROUP $ZIMBRA_HOME/$i
		fi
	done

	## scan for probably wrong ownerships
	find $ZIMBRA_HOME/mailboxd/webapps -not -user zimbra -or -not -group zimbra -exec "echo" "WARN: probably wrong ownership:" "{}" ";"
}

dpkg_call() {
	dpkg_init
	su $ZIMBRA_USER -- fakeroot-ng dpkg --force-architecture --force-not-root --root=$ZIMBRA_HOME --log=$ZIMBRA_HOME/var/log/dpkg.log "$@"
}

## only want to run as unprivileged user
[ `whoami` != 'root' ] && err "I wanna run as root"

if [ ! "$1" ]; then
	zmpkg_help
fi

ZIMBRA_HOME="$1"

if ! fakeroot-ng /bin/true ; then
	err "$0: fakeroot needs to be installed"
fi

if ! dpkg --help >/dev/null ; then
	err "$0: dpkg needs to be installed"
fi

dpkg_call -i zcs-zmpkg*.deb
