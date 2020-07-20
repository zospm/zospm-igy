#!/bin/sh
#
# Run a basic COBOL install/configure
#
. zospmsetenv
#set -x

# Clear up any jetsam from a previous run
zospm deconfigure igy630
zospm uninstall igy630

zosinfo=`uname -rsvI`
version=`echo ${zosinfo} | awk '{ print $3; }'`
release=`echo ${zosinfo} | awk '{ print $2; }'`

case ${release} in
	'03.00' )
                export ZOSPM_CEE230_CSI='MVS.GLOBAL.CSI'
		;;
	'04.00' )
                export ZOSPM_CEE240_CSI='MVS.GLOBAL.CSI'
		;;
esac

#
# Add in the following once we get a base system with z/OS 2.4 
# installed (right now it will fail due to lack of PTFs installed)
#
zospm install igy630
rc=$?
if [ $rc != 0 ]; then
	echo "zospm install failed with rc:$rc" >&2
	exit 3
fi

zospm configure igy630
rc=$?
if [ $rc != 0 ]; then
	echo "zospm configure failed with rc:$rc" >&2
	exit 4
fi

# disabled this test for now ... have to update tests to read BOM to find mountpoints and verify
#bindir="${ZOSPM_SRC_ZFSROOT}bin"
#if ! [ -d "${bindir}" ]; then
#	zospmtest "leaf directory not created" "${bindir}" "${bindir}"
#	exit 6
#fi

exit 0
