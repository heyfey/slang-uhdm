#!/bin/bash
# svrow.sh <bin> <row (generated/.../x)> <out.uhdm> [ENV=VAL]: one export of an sv-tests
# row with the slang command line the master's control recorded (cmds.txt), from
# the control's row directory.  Single process.
B=$1; R=$2; O=$3; shift 3
D=/tmp/intr11u477/svtests/work/$R
L=$(grep '^slang:' $D/cmds.txt | sed 's/^slang: *//; s# -o [^ ]*$##')
set -- $L; shift
rm -f "$O"; (cd $D && env "${ENVS[@]}" $EXTRA "$B" "$@" -o "$O" >/dev/null 2>&1 </dev/null); echo "rc=$? md5=$(md5sum < $O | cut -c1-10)"
