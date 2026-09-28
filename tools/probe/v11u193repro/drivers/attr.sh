#!/bin/bash
# attr.sh <probe rel path>: which single R11U193 switch moves law.bin's bytes on this tests/probe case
. "$(dirname "$0")/env.sh" || exit 3
rel=$1; v193_fenced "$rel" && exit 0; D=$REPO/tests/probe/$rel; T=/tmp/v11u193_attr/$(echo $rel | tr / _); mkdir -p $T
(cd $D && $V193_BIN/law.bin dut.sv --single-unit --nobuiltin -o $T/base.uhdm >/dev/null 2>&1); b=$(md5sum < $T/base.uhdm)
out=""
for s in CASTLEAF CASTTSNAME SYSARGDEF TERNFILL UNSIZEDCLONE NESTNAME COPYORDER; do rm -f $T/o.uhdm; (cd $D && env R11U193_${s}_OFF=1 $V193_BIN/law.bin dut.sv --single-unit --nobuiltin -o $T/o.uhdm >/dev/null 2>&1); [ "$(md5sum < $T/o.uhdm)" != "$b" ] && out="$out$s,"; done
echo "$rel $out"
