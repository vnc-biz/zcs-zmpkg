#!/bin/bash


[ "$ZIMBRA_HOME"  ] || ZIMBRA_HOME=/opt/zimbra
LOG_FILE="/tmp/zmpkg_fix_permission.log"

die() {
        echo "== ERROR: $*" >&2
        exit 1
}

[ `whoami` != 'root' ] && die "I wanna run as root"

help() {
        (
                echo "$0 [--zimbra-root <zimbra_root>] [--help]"
                echo ""
                echo "Zimbra Package Management after upgrade permission fix script."
                echo ""
                echo "Optional arguments:"
                echo "--zimbra-root <zimbra_root>     non-standard zimbra installation directory"
                echo ""
        ) >&2
        exit 2 
}

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

read -p "Did you run bootstrap installation again after upgrade?[Y/n]:" ans

case $ans in
	[nN]* ) 
		echo "Please run bootstrap installation before running this script."
		exit 0
	;;
esac

echo "ZMPKG permission fix script started at $(date)" >> $LOG_FILE

for I in `su zimbra -c "$ZIMBRA_HOME/bin/zmpkg list" | grep -E "^ii" | awk '{print $2}'`; do echo "Reinstalling $I......"; su zimbra -c "$ZIMBRA_HOME/bin/zm-apt-get -y --reinstall install $I" 2>&1 >> $LOG_FILE; done

for line in `cat $ZIMBRA_HOME/var/lib/dpkg/info/*.list`
do
	if [[ $line =~ \.(js|zgz|jar|sql)$ ]]; then
		echo "Fixing permission of $ZIMBRA_HOME$line"
		chown zimbra:zimbra "$ZIMBRA_HOME$line" 2>&1 >> $LOG_FILE
	fi
done

echo "Check logfile $LOGFILE for more information. And restart your mailbox service."
