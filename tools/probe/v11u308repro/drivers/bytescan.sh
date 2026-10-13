#!/bin/bash
# v11u308 bytescan.sh <pristine bin> <law bin> <out> [view d|e]: EVERY dut.sv dir under tools/probe and
# tests/probe (the path list built first and filtered by $FENCED before any file is opened), both binaries
# from the same directory with the same output name; one line per dir: `<dir> <rcP> <rcL> SAME|MOVE|NODB`.
# The byte census of the law over the whole probe tree (a law that moves bytes without a trace line is seen).
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "bytescan.sh: FENCED unset" >&2; exit 2; }
P=$1; L=$2; O=$3; V=${4:-d}
for b in "$P" "$L"; do [ -x "$b" ] || { echo "bytescan.sh: binary not executable" >&2; exit 2; }; done
H=$(cd "$(dirname "$0")" && pwd); R=$(cd "$H/../../../.." && pwd)
FR="\\b($(echo $FENCED | tr ' ' '|'))\\b"
W=$(mktemp -d /tmp/v11u308_bscan.XXXXXX)
(cd $R && find tools/probe tests/probe -name dut.sv | sort) | grep -vP "$FR" | sed 's#/dut.sv$##' > $W/list
echo "listed $(wc -l < $W/list)" >&2
EX=""; [ "$V" = e ] && EX="--elabuhdm"
export R W P L EX
cat $W/list | xargs -P ${JOBS:-4} -I{} bash -c 'd={}; k=$(echo "$d" | md5sum | cut -c1-16); o=$W/$k.uhdm
  rm -f $o; (cd $R/$d && timeout 120 $P dut.sv --single-unit --nobuiltin $EX -o $o >/dev/null 2>&1 </dev/null); rp=$?; mp=$( [ -s $o ] && md5sum < $o | cut -c1-16 || echo none); rm -f $o
  (cd $R/$d && timeout 120 $L dut.sv --single-unit --nobuiltin $EX -o $o >/dev/null 2>&1 </dev/null); rl=$?; ml=$( [ -s $o ] && md5sum < $o | cut -c1-16 || echo none); rm -f $o
  s=SAME; [ "$mp" != "$ml" ] && s=MOVE; [ "$mp" = none ] && [ "$ml" = none ] && s=NODB
  echo "$d $rp $rl $s"' | sort > $O
rm -rf $W
echo "processed $(wc -l < $O)" >&2
