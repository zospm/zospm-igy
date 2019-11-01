#!/bin/sh
#set -x

out=$(whence zoscloudfuncs >/dev/null)
if [ $? -eq 0 ]; then
	. zoscloudfuncs
else
	echo "zoscloud tools need to be in your PATH"
	exit 4
fi


crtds() {
	list=$1
	echo "$1" | awk '{ ds=$1; $1=""; attrs=$0; if ($ds != "") { rc=system("dtouch " attrs " " ds); if (rc > 0) { exit(rc); } } }'
	exit $?
}

crtzfs() {
	root=$1 
	middle='/usr/lpp/IBM/cobol/igyv6r3/'
	mkdir -p -m 755 ${root}${middle}
	rc=$?
	if [ $rc -gt 0 ]; then
		exit $rc
	fi

	mvscmdauth --pgm=IDCAMS --sysprint='*' --sysin=stdin <<zzz
   DEFINE CLUSTER(NAME(${IGYHLQ}.ZFS) -
   LINEAR CYLINDERS(2 1) SHAREOPTIONS(3)
zzz
	rc=$?
	if [ $rc -gt 0 ]; then
		exit $rc
	fi
	mvscmdauth --pgm=IOEAGFMT --args="-aggregate ${IGYHLQ}.ZFS -compat" --sysprint='*'
	rc=$?
	if [ $rc -gt 0 ]; then
		exit $rc
	fi
	/usr/sbin/mount -t zfs -f ${IGYHLQ}.ZFS ${root}${middle}
	rc=$?
	if [ $rc -gt 0 ]; then
		exit $rc
	fi

	leaves='bin/.orig bin/IBM lib/nls/msg/C lib/nls/msg/Ja_JP include demo/oosample'
	for l in $leaves; do
		mkdir -p -m 755 ${root}${middle}${l}
		rc=$?
		if [ $rc -gt 0 ]; then
			exit $rc
		fi
	done
	exit 0
}

crtddef() {
targetsmpcntl=\
" SET   BDY(${IGYSMPTGT}).
 UCLIN.
  ADD DDDEF(SIGYMAC)
      DA(${IGYHLQ}.SIGYMAC)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
  ADD DDDEF(SIGYCOMP)
      DA(${IGYHLQ}.SIGYCOMP)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
  ADD DDDEF(SIGYPROC)
      DA(${IGYHLQ}.SIGYPROC)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
  ADD DDDEF(SIGYSAMP)
      DA(${IGYHLQ}.SIGYSAMP)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
  ADD DDDEF(AIGYHFS)
      DA(${IGYHLQ}.AIGYHFS)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
  ADD DDDEF(AIGYMOD1)
      DA(${IGYHLQ}.AIGYMOD1)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
  ADD DDDEF(AIGYSRC1)
      DA(${IGYHLQ}.AIGYSRC1)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
  ADD DDDEF(SIGYHFS)
      PATH('${IGYROOT}/usr/lpp/IBM/cobol/igyv6r3/bin/IBM/').
 ENDUCL."

distsmpcntl=\
" SET   BDY(${IGYSMPDIST}).
 UCLIN.
  ADD DDDEF(AIGYHFS)
      DA(${IGYHLQ}.AIGYHFS)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
  ADD DDDEF(AIGYMOD1)
      DA(${IGYHLQ}.AIGYMOD1)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
  ADD DDDEF(AIGYSRC1)
      DA(${IGYHLQ}.AIGYSRC1)
      UNIT(SYSALLDA)
      WAITFORDSN
      SHR.
 ENDUCL."

	mvscmdauth --pgm=GIMSMP --smpcsi=${IGYGLOBALCSI}  --smppts=TST.SMPPTS --smplog='*' --smpout='*' --smprpt='*' --smplist='*' --sysprint='*'  --smpcntl=stdin <<zzz
${targetsmpcntl}
zzz
	rc=$?
	if [ $rc -gt 0 ]; then
		exit $rc
	fi

	mvscmdauth --pgm=GIMSMP --smpcsi=${IGYGLOBALCSI} --smplog='*' --smpout='*' --smprpt='*' --smplist='*' --sysprint='*' --smpcntl=stdin <<zzz
${distsmpcntl}
zzz
	rc=$?
	exit $rc
}

props=$(callerdir "$0")"/igy630config.properties"
. zoscloudprops ${props}

ds="
    	${IGYHLQ}.SIGYCOMP -s150M -ru
	${IGYHLQ}.SIGYMAC -s1M
	${IGYHLQ}.SIGYPROC -s1M
	${IGYHLQ}.SIGYSAMP -s1M
"

out=`crtds "${ds}"`
rc=$?
if [ $rc -gt 0 ]; then
	echo "Dataset creation failed. Installation aborted"
	exit $rc
fi

out=`crtzfs "${IGYROOT}"`
rc=$?
if [ $rc -gt 0 ]; then
	echo "zFS File system creation failed. Installation aborted"
	exit $rc
fi

out=`crtddef`
rc=$?
if [ $rc -gt 0 ]; then
	echo "SMP Data Definition failed. Installation aborted"
	echo "$out"
	exit $rc
fi

exit 0
