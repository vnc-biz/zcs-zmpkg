#!/bin/bash

ME="$0"

err() {
	echo "$ME: $*" >&2
	exit 1
}

## only want to run as unprivileged user
[ `whoami` == 'root' ] && err "dont wanna run as root"

DPKG_ROOT=$HOME

dpkg_init() {
	mkdir -p \
		$DPKG_ROOT/var/lib/dpkg			\
		$DPKG_ROOT/var/lib/dpkg/updates		\
		$DPKG_ROOT/var/lib/dpkg/triggers	\
		$DPKG_ROOT/var/lib/dpkg/info		\
		$DPKG_ROOT/var/log			\
		$DPKG_ROOT/.tmp				\

	touch	\
		$DPKG_ROOT/var/lib/dpkg/status	\
		$DPKG_ROOT/var/lib/dpkg/available

	for i in start-stop-daemon ldconfig ; do
		(echo "#!/bin/bash" ; echo "exit 0" ) > $DPKG_ROOT/.tmp/$i
		chmod +x $DPKG_ROOT/.tmp/$i
	done
}

dpkg_call() {
	dpkg_init
	PATH="$DPKG_ROOT/.tmp:$PATH" dpkg --root=$DPKG_ROOT --log=$DPKG_ROOT/var/log/dpkg.log "$@"
}

zmpkg_help() {
	echo "$ME install <deb-file-name>"
	echo "$ME remove <package-name>"
	echo "$ME list"
	exit 1
}

zmpkg_install() {
	[ "$1" ] || zmpkg_help
	dpkg_call -i "$*"
}

zmpkg_install @DEBFILE@
