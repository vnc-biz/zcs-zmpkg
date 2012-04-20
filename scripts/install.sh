#!/bin/bash

ME="$0"

err() {
	echo "$ME: $*" >&2
	exit 1
}

zmpkg_help() {
	echo "$ME <zimbra-user> <zimbra-root>" >&2
	exit 1
}

dpkg_init() {
	mkdir -p \
		$ZIMBRA_HOME/var/lib/dpkg		\
		$ZIMBRA_HOME/var/lib/dpkg/updates	\
		$ZIMBRA_HOME/var/lib/dpkg/triggers	\
		$ZIMBRA_HOME/var/lib/dpkg/info		\
		$ZIMBRA_HOME/var/log			\
		$ZIMBRA_HOME/.tmp			\

	touch	\
		$ZIMBRA_HOME/var/lib/dpkg/status	\
		$ZIMBRA_HOME/var/lib/dpkg/available

	chown -R $ZIMBRA_USER	$ZIMBRA_HOME/var/ $ZIMBRA_HOME/bin

	find /opt/zimbra -type d | xargs chown $ZIMBRA_USER
}

dpkg_call() {
	dpkg_init
	su $ZIMBRA_USERNAME -- fakeroot dpkg --force-architecture --force-not-root --root=$ZIMBRA_HOME --log=$ZIMBRA_HOME/var/log/dpkg.log "$@"
}

## only want to run as unprivileged user
[ `whoami` != 'root' ] && err "I wanna run as root"

if [ ! "$2" ]; then
	zmpkg_help
fi

ZIMBRA_USER="$1"
ZIMBRA_HOME="$2"
ZIMBRA_USERNAME=`echo "$ZIMBRA_USER" | sed -e 's/:.*//'`

if ! fakeroot /bin/true ; then
	err "$0: fakeroot needs to be installed"
fi

if ! dpkg --help >/dev/null ; then
	err "$0: dpkg needs to be installed"
fi

dpkg_call -i zcs-zmpkg_1.0.1_All.deb
