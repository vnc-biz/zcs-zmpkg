#!/bin/bash

ME="$0"

ZIMBRA_USER="zimbra"
ZIMBRA_GROUP="zimbra"

ZIMBRA_DIRS="
    /var/lib
    /var/lib/dpkg
    /var/lib/dpkg/updates
    /var/lib/dpkg/triggers
    /var/lib/dpkg/info
    /var/log/
    /.aptitude
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

warn() {
	echo "== WARNING: $*" >&2
}

check_fakeroot() {
	FAKEROOT_VERSION=`fakeroot -v`
	case "$FAKEROOT_VERSION" in
		*fakeroot\ version\ *)
			echo "Fakeroot ok: $FAKEROOT_VERSION"
		;;
		*fakeroot-ng\ version\ *)
			err "Cant work with fakeroot-ng - need plain fakeroot"
		;;
		*)
			err "Cant find fakeroot. Please install fakeroot (NOT fakeroot-ng)"
		;;
	esac
}

check_fakeroot

zmpkg_help() {
	echo "$ME <zimbra-root>" >&2
	exit 1
}

dpkg_init() {
	for i in $ZIMBRA_DIRS ; do
		echo "processing: $i"
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

	## fix architectures of already installed packages
	DPKG_DB=$ZIMBRA_HOME/var/lib/dpkg
	for i in status available ; do
		touch $DPKG_DB/$i
		cat $DPKG_DB/$i | sed -e 's~Architecture: All~Architecture: all~' > $DPKG_DB/$i.tmp
		mv $DPKG_DB/$i.tmp $DPKG_DB/$i
		chown $ZIMBRA_USER:$ZIMBRA_GROUP $DPKG_DB/$i
	done
}

dpkg_call() {
	dpkg_init
	su $ZIMBRA_USER -c "PATH=\"$ZIMBRA_HOME/extensions-extra/zmpkg/tools/:$PATH\" /usr/bin/fakeroot /usr/bin/dpkg --force-architecture --force-not-root --root=$ZIMBRA_HOME --log=$ZIMBRA_HOME/var/log/dpkg.log $*"
}

## only want to run as unprivileged user
[ `whoami` != 'root' ] && err "I wanna run as root"

if [ ! "$1" ]; then
	zmpkg_help
fi

ZIMBRA_HOME="$1"

if ! fakeroot /bin/true ; then
	err "$0: fakeroot needs to be installed"
fi

if ! dpkg --help >/dev/null ; then
	err "$0: dpkg needs to be installed"
fi

if ! apt-get --help >/dev/null ; then
	warn "apt-get not installed -> zm-apt-get wont be available"
	NON_DEBIAN=1
fi

if ! aptitude --help >/dev/null; then
	warn "aptitude not installed -> zm-aptitude wont be available"
	NON_DEBIAN=1
fi

if [ "$NON_DEBIAN" ]; then
	warn "Looks like you're not Debian or Ubuntu"
	warn "Please refer to documentation on how to install on rpm-based distros"
	warn "(sleeping for 5 seconds ...)"
	sleep 5
fi

dpkg_call -i zcs-zmpkg*.deb
dpkg_call -i zcs-zmpkg*.deb
dpkg_call -i zcs-zmpkg*.deb
