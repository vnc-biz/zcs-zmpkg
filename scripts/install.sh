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
if [ -f /etc/SuSE-release ]; then
	DISTRIB_ID=SuSE
	DISTRIB_RELEASE=`cat /etc/SuSE-release`
elif [ -f /etc/debian_version ]; then
	DISTRIB_ID=Debian
	DISTRIB_RELEASE=`cat /etc/debian_version`
elif [ -f /etc/centos-release ]; then
	DISTRIB_ID=CentOS
	DISTRIB_RELEASE=`cat /etc/centos-release | sed -e 's~CentOS release ~~i; s~^\ *~~; s~\ .*~~;'`
elif [ -f /etc/redhat-release ]; then
	DISTRIB_ID=RedHat
	DISTRIB_RELEASE=`cat /etc/redhat-release`
elif [ -f /etc/lsb-release ]; then
	. /etc/lsb-release
fi

if [ "$DISTRIB_ID" ]; then
	echo "$DISTRIB_ID ($DISTRIB_RELEASE)"
else
	echo "UNKNOWN"
	die "Unable to detect your distro, cannot proceed. You'll need to do manual install :("
fi

help() {
	(
		echo "$0 [--zimbra-root <zimbra_root>] [--zimbra-user <zimbra_user>] [--zimbra-group <zimbra_group>] [--help]"
		echo ""
		echo "Zimbra Package Management bootstrap installer"
		echo ""
		echo "Optional arguments:"
		echo "--zimbra-root <zimbra_root>     non-standard zimbra installation directory"
		echo "--zimbra-user <zimbra_user>     non-standard zimbra user"
		echo "--zimbra-group <zimbra_group>   non-standard zimbra group"
		echo ""
	) >&2
	exit 666
}

while [ "$1" ]; do
	case "$1" in
		-h|-help|--help)
			help
		;;
		--zimbra-root|-r)
			shift
			[ "$1" ] || die "missing zimbra root directory"
			ZIMBRA_ROOT="$1"
		;;
		--zimbra-user|-u)
			shift
			[ "$1" ] || die "missing zimbra user"
			ZIMBRA_USER="$1"
		;;
		--zimbra-group|-g)
			shift
			[ "$1" ] || die "missing zimbra group"
			ZIMBRA_GROUP="$1"
		;;
		*)
			die "unsupported option: $1"
		;;
	esac
done

dummy_progs() {
	if [ ! -f /usr/local/sbin/update-rc.d ]; then
		ln -sf /bin/true /usr/local/sbin/update-rc.d
	fi
}

## install prerequisites
prepare_debian() {
	apt-get update && apt-get install fakeroot aptitude unzip
}

## FIXME: we need to separate between distro releases --- currently just assuming RHEL6/CENTOS6
prepare_redhat() {
	VERSION=`echo $DISTRIB_RELEASE | awk -F "release" '{ print $2 }' | cut -d" " -f 2`
	if [ $(echo "$VERSION > 5" | bc) -ne 0 ] && [ $(echo "$VERSION < 6" | bc) -ne 0 ] ; then
		echo "Detected OS version 5.x"	
		case `arch` in
			x86_64)
				yum --nogpgcheck install binpkg/RHEL/x86_64/@RPM_RHEL5_64_DPKG@ \
							 binpkg/RHEL/x86_64/@RPM_RHEL5_64_APT@	 \
							 binpkg/RHEL/x86_64/@RPM_RHEL5_64_FAKEROOT@	
			;;
			i386|i686)
				yum --nogpgcheck install binpkg/RHEL/i686/@RPM_RHEL5_32_DPKG@ \
							 binpkg/RHEL/i686/@RPM_RHEL5_32_APT@	 \
							 binpkg/RHEL/i686/@RPM_RHEL5_32_FAKEROOT@ \
							 binpkg/RHEL/i686/@RPM_RHEL5_32_FAKEROOT_LIBS@	
			;;
			*)
				die "Unsupported host architecture:" `arch`
			;;
		esac
		ldconfig
                dummy_progs
	else
		echo "Detected OS version $VERSION"
		## install fakeroot
		yum update -y
		yum install -y fakeroot
		yum install -y unzip

		## install dpkg
		case `arch` in
			x86_64)
				yum install -y \
					binpkg/RHEL/x86_64/@RPM_RHEL_64_DPKG@	\
					binpkg/RHEL/x86_64/@RPM_RHEL_64_APT@	
					
			;;
			i386|i686)
				yum install -y \
					binpkg/RHEL/i686/@RPM_RHEL_32_DPKG@
			;;
			*)
				die "Unsupported host architecture: " `arch`
			;;
		esac
		ldconfig
		dummy_progs
	fi;
}

prepare_suse() {
	zypper install unzip
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
	dummy_progs
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

CREATE_DIRS="
	$ZIMBRA_HOME/extensions-extra/zmpkg
	$ZIMBRA_HOME/extensions-extra/zmpkg/etc/apt
	$ZIMBRA_HOME/extensions-extra/zmpkg/etc/apt/conf.d
	$ZIMBRA_HOME/.gnupg
"

mkdir -p $CREATE_DIRS
chown -R $ZIMBRA_USER:$ZIMBRA_GROUP $CREATE_DIRS

## call the actual installers

cd zmpkg/$ZIMBRA_DIST/*/ || err "cannot chdir to $ZIMBRA_DIST installer"

echo
echo " == Now calling the zmpkg for $ZIMBRA_DIST installer ..."
echo

./install.sh $ZIMBRA_HOME || die "zmpkg installation failed"

echo
echo " == Setting up VNC repo == "
echo

sources_list() {
    echo "## automatic entry generated by bootstrap install"
    echo "## NOTE: you should retain formatting (spaces instead of tabs)"
    echo "##       for further automatic config upgrades to work"
    echo "deb http://packages.vnc.biz/zmpkg/current $ZIMBRA_DIST free restricted commercial"
    echo ""
    echo "## add your own repos below"
    echo ""
}

SOURCES_LIST=$ZIMBRA_HOME/extensions-extra/zmpkg/etc/apt/sources.list

if [ -f $SOURCES_LIST ]; then
    (
	echo ""
	echo " WARNING: $SOURCES_LIST already existing ..."
	echo "          writing new to: $SOURCES_LIST.new"
	echo ""
    ) >&2

    sources_list > $SOURCES_LIST.new
else
    echo "Creating new $SOURCES_LIST"
    sources_list > $SOURCES_LIST
fi

chown -R $ZIMBRA_USER:$ZIMBRA_GROUP $CREATE_DIRS

## fix permissions for extension installation
find $ZIMBRA_HOME/lib/ext -type d -exec "chown" "$ZIMBRA_USER:$ZIMBRA_GROUP" "{}" ";"

su zimbra -l -c "zm-apt-key add $ZIMBRA_HOME/extensions-extra/zmpkg/etc/apt/zcs-repo-master.key"
su zimbra -l -c "zm-apt-get update"
su zimbra -l -c "zm-apt-get upgrade"
