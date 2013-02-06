#!/bin/bash

die() {
	echo "== ERROR: $*" >&2
	exit 1
}

[ "$ZIMBRA_HOME"  ] || ZIMBRA_HOME=/opt/zimbra
[ "$ZIMBRA_USER"  ] || ZIMBRA_USER=zimbra
[ "$ZIMBRA_GROUP" ] || ZIMBRA_GROUP=zimbra

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
elif [ -f /etc/SuSE-release ]; then
	DISTRIB_ID=SuSE
	DISTRIB_RELEASE=`cat /etc/SuSE-release`
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
			yum install \
				binpkg/RHEL/x86_64/dpkg-1.15.5.6-6.el6.x86_64.rpm	\
				binpkg/RHEL/x86_64/apt-0.8.16.1-0.8.16.1.x86_64.rpm
		;;
		i386|i686)
			yump install \
				binpkg/RHEL/i686/dpkg-1.15.5.6-6.el6.i686.rpm
		;;
		*)
			die "Unsupported host architecture: " `arch`
		;;
	esac
}

prepare_suse() {
	for i in \
		fakeroot-1.18.3-1.1.x86_64.rpm			\
		dpkg-1.16.8-7.1.x86_64.rpm			\
		libapt-pkg4_12-0.8.16-7.3.x86_64.rpm		\
		debhelper-9.20120830-5.1.noarch.rpm		\
		apt-debian-0.8.16-7.3.x86_64.rpm		\
		apt-transport-https-0.8.16-7.3.x86_64.rpm	; do
	    rpm -i binpkg/SLES/x86_64/$i || die "Failed to install: $i"
	done
	if [ ! -d /usr/lib/apt ]; then
		echo "Fixing symlink for apt ..."
		( cd /usr/lib && ln -sf /usr/lib64/apt )
	fi
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
		ZIMBRA_DIST=helix
		echo "Helix (ZCS 7.x)"
	;;
	Release\ 8*)
		ZIMBRA_DIST=ironmaiden
		echo "IronMaiden (ZCS 8.x)"
	;;
	*)
		echo "UNKNOWN"
		echo "== FATAL: UNSUPPORTED OR MISSING ZIMBRA VERSION ==" >&2
		exit 1
	;;
esac

## call the actual installers

cd zmpkg/$ZIMBRA_DIST/*/ || err "cannot chdir to $ZIMBRA_DIST installer"

echo
echo " == Now calling the zmpkg for $ZIMBRA_DIST installer ..."
echo

./install.sh $ZIMBRA_HOME || die "zmpkg installation failed"

echo
echo " == Setting up VNC repo == "
echo

mkdir -p $ZIMBRA_HOME/extensions-extra/zmpkg/etc/apt
(
    echo "## automatic entry generated by bootstrap install"
    echo "## NOTE: you should retain formatting (spaces instead of tabs)"
    echo "##       for further automatic config upgrades to work"
    echo "deb http://packages.vnc.biz/zmpkg/current $ZIMBRA_DIST free restricted"
    echo ""
    echo "## add your own repos below"
    echo ""
) > $ZIMBRA_HOME/extensions-extra/zmpkg/etc/apt/sources.list

chown -R $ZIMBRA_USER:$ZIMBRA_GROUP $ZIMBRA_HOME/extensions-extra/zmpkg

su zimbra -l -c "zm-apt-key add $ZIMBRA_HOME/extensions-extra/zmpkg/etc/apt/zcs-repo-master.key"
su zimbra -l -c "zm-apt-get update"
su zimbra -l -c "zm-apt-get upgrade"
