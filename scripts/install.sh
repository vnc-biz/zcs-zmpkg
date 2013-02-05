#!/bin/bash

err() {
	echo "== ERROR: $*" >&2
	exit 1
}

[ "$ZIMBRA_HOME" ] || ZIMBRA_HOME=/opt/zimbra

echo
echo "Welcome to the ZMPKG installer"
echo

## check if zimbra is installed
echo -n "checking for Zimbra installed ..."
if [ ! -e $ZIMBRA_HOME/bin/zmcontrol ]; then
	err "Cannot find zmcontrol ... is your Zimbra really installed at $ZIMBRA_HOME ?"
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
