#!/bin/bash

die() {
	echo "== ERROR: $*" >&2
	exit 1
}

[ "$ZIMBRA_HOME" ] || ZIMBRA_HOME=/opt/zimbra

echo
echo "Welcome to the ZMPKG installer"
echo

## detect the distro
echo -n "Checking your distro ... "
if [ -f /etc/lsb-release ]; then
	. /etc/lsb-release
elif [ -f /etc/debian_version ]; then
	DISTRIB_ID=Debian
	DISTRIB_RELEASE=`cat /etc/debian_version`
elif [ -f /etc/centos-release ]; then
	DISTRIB_ID=CentOS
	DISTRIB_RELEASE=`cat /etc/centos-release | sed -e 's~CentOS release ~~i; s~^\ *~~; s~\ .*~~;'`
elif [ -f /etc/redhat-release ]; then
	DISTRIB_ID=RedHat
	DISTRIB_RELEASE=`cat /etc/redhat-release`
fi

if [ "$DISTRIB_ID" ]; then
	echo "$DISTRIB_ID ($DISTRIB_RELEASE)"
else
	echo "UNKNOWN"
	die "Unable to detect your distro, cannot proceed. You'll need to do manual install :("
fi

## install prerequisites
prepare_debian() {
	apt-get update && apt-get install fakeroot aptitude
}

## FIXME: we need to separate between distro releases --- currently just assuming RHEL6/CENTOS6
prepare_redhat() {
	## install fakeroot
	yum install fakeroot

	## install dpkg
	case `arch` in
		x86_64)
			yum install http://dl.fedoraproject.org/pub/epel/6/x86_64/dpkg-1.15.5.6-6.el6.x86_64.rpm
		;;
		i386)
			yum install http://dl.fedoraproject.org/pub/epel/6/i386/dpkg-1.15.5.6-6.el6.i686.rpm
		;;
		i686)
			yump install http://dl.fedoraproject.org/pub/epel/6/i386/dpkg-1.15.5.6-6.el6.i686.rpm
		;;
		*)
			die "Unsupported host architecture: " `arch`
		;;
	esac
}

prepare_suse() {
	die "SuSE not supported yet :("
}

case "$DISTRIB_ID" in
	Debian)
		prepare_debian
	;;
	Ubuntu)
		prepare_debian
	;;
	CentOS)
		prepare_redhat
	;;
	RedHat)
		prepare_redhat
	;;
	SuSE)
		prepare_suse
	;;
	*)
		die "Unsupported distro $DISTRIB_ID, cannot proceed. You'll need to do manual install :("
	;;
esac

## check if zimbra is installed
echo -n "checking for Zimbra installed ... "
if [ ! -e $ZIMBRA_HOME/bin/zmcontrol ]; then
	echo "MISSING"
	die "Cannot find zmcontrol ... is your Zimbra really installed at $ZIMBRA_HOME ?"
fi
echo

## detect zimbra base version
echo -n "checking for Zimbra version ... "

ZIMBRA_VERSION=`su zimbra -c "/opt/zimbra/bin/zmcontrol -v" 2>/dev/null | grep "Release"`

case "$ZIMBRA_VERSION" in
	Release\ 7*)
		ZIMBRA_BASE=helix
		echo "Helix (ZCS 7.x)"
	;;
	Release\ 8*)
		ZIMBRA_BASE=ironmaiden
		echo "IronMaiden (ZCS 8.x)"
	;;
	*)
		echo "UNKNOWN"
		echo "== FATAL: UNSUPPORTED OR MISSING ZIMBRA VERSION ==" >&2
		exit 1
	;;
esac

## call the actual installers

cd zmpkg/$ZIMBRA_BASE/*/ || err "cannot chdir to $ZIMBRA_BASE installer"

echo
echo " == Now calling the zmpkg for $ZIMBRA_BASE installer ..."
echo

./install.sh $ZIMBRA_HOME
