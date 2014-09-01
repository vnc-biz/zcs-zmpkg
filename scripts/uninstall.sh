#!/bin/bash

die() {
	echo "== ERROR: $*" >&2
	exit 1
}

if [[ $EUID -ne 0 ]]; then
	die "Oops. Run me with root user."
fi;

[ "$ZIMBRA_HOME"  ] || ZIMBRA_HOME=/opt/zimbra

echo
echo "Welcome to the ZMPKG uninstaller"
echo

help() {
	(
		echo "$0 [--zimbra-root <zimbra_root>] [--help]"
		echo ""
		echo "Zimbra Package Management bootstrap uninstaller"
		echo ""
		echo "Optional arguments:"
		echo "--zimbra-root <zimbra_root>     non-standard zimbra installation directory"
		echo ""
	) >&2
	exit 666
}

echo 

while [ "$1" ]; do
	case "$1" in
		-h|-help|--help)
			help
		;;
		--zimbra-root|-r)
			shift
			[ "$1" ] || die "missing zimbra root directory"
			ZIMBRA_HOME="$1"
		;;
		*)
			die "unsupported option: $1"
		;;
	esac
done

echo "Checking Zimbra status..."
MAILBOXSTATUS=`su zimbra -c "$ZIMBRA_HOME/bin/zmcontrol status | grep mailbox | tr -s [:space:] | cut -d' ' -f2"`
if [ "$MAILBOXSTATUS" != "Running" ] ; then
        echo "Mailbox is not running. Start mailbox and then run the script again."
	exit 1
fi;

CMD_ZMPKG=$ZIMBRA_HOME/bin/zmpkg
CMD_ZMPKG_AUTODEPLOY=$ZIMBRA_HOME/bin/zmpkg-autodeploy
LOG_FILE="/tmp/zmpkg_uninstall.log"
CMD_RM="rm -r"
ZMPKG_PATHS="$ZIMBRA_HOME/extensions-extra/ $ZIMBRA_HOME/.aptitude $ZIMBRA_HOME/.tmp $ZIMBRA_HOME/packages $ZIMBRA_HOME/services $ZIMBRA_HOME/bin/zmpkg $ZIMBRA_HOME/bin/zm_check_jsp $ZIMBRA_HOME/bin/zm-apt-cache $ZIMBRA_HOME/bin/zm-apt-config $ZIMBRA_HOME/bin/zm-apt-get $ZIMBRA_HOME/bin/zm-aptitude $ZIMBRA_HOME/bin/zm-apt-key $ZIMBRA_HOME/bin/_zmapt_wrapper $ZIMBRA_HOME/bin/zmpkg-autodeploy $ZIMBRA_HOME/bin/zmpkg-devel-init $ZIMBRA_HOME/bin/zmpkg-dpkg $ZIMBRA_HOME/var $ZIMBRA_HOME/.gnupg"

read -p "This will remove all the packages installed and zmpkg itself from your system. Do you want to continue?[Y/n]:" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then 
	echo
	echo "Removing all VNC packages..."
	echo
	#Fix this: Remove zcs-core-libs from the grep command as it's kept for zcs-core-libs uninstallation problem. See the bug #8926 
	su zimbra -c "$CMD_ZMPKG list | grep -E \"^(ii|ri)\" | grep -v \"zcs-zmpkg|zcs-core-libs\" | awk -F\" \" '{print \$2}' | xargs -n 1 $CMD_ZMPKG dpkg -r --force-depends" > $LOG_FILE  2>&1
	su zimbra -c "$CMD_ZMPKG_AUTODEPLOY" 2>&1 >> $LOG_FILE 
	
	echo "Removing zmpkg..."
	for filepath in $ZMPKG_PATHS; do
		$CMD_RM $filepath 2>&1 >> $LOG_FILE
	done;
	echo 
	echo "Uninstallation complete. Restart Zimbra."
	exit 0
else
	exit 0
fi;
