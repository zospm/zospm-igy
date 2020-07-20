#!/bin/sh
#*******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2019. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#*******************************************************************************
#
# Run through each of the tests in the test bucket that aren't 
# explicitly excluded, and return the highest error code
#
. zospmsetenv
export PATH=$ZOSPM_ROOT/testtools:$PATH

. zospmtestfuncs   

#
# Override the ZOSPM_SRC_HLQ to ensure test datasets go to separate location from standard work
#
export ZOSPM_SRC_HLQ=ZOSPMVS.
export ZOSPM_SRC_ZFSROOT=/zospm/igyvs/
export ZOSPM_TGT_HLQ=ZOSPMVT.
export ZOSPM_TGT_ZFSROOT=/zospm/igyvt/

runtests "${mydir}/tests" "$1"
exit $?
