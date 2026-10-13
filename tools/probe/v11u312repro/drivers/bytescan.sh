#!/bin/bash
# v11u312 bytescan.sh <pristine bin> <law bin> <out> [view d|e]: the whole-tree byte scan.  Every dut.sv dir under
# tools/probe and tests/probe (the path list built first and filtered by $FENCED by word boundary before any file
# is opened), both binaries on the same dir with the same arguments (view e adds --elabuhdm; 120 s timeout);
# one line per dir: `<dir> <view> P rc=<n> <md5> L rc=<n> <md5> SAME|MOVE`.  Fail-closed on $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "bytescan.sh: FENCED unset" >&2; exit 2; }
P=$1; L=$2; O=$3; V=${4:-d}; [ -x "$P" ] && [ -x "$L" ] || { echo "bytescan.sh: binaries" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); R=$(cd "$H/../../../.." && pwd)
FR="\\b($(echo $FENCED | tr ' ' '|'))\\b"
W=$(mktemp -d /tmp/v11u312_bscan.XXXXXX)
(cd $R && find tools/probe tests/probe -name dut.sv | sort) | grep -vP "$FR" | sed 's#/dut.sv$##' > $W/list
wc -l < $W/list >&2
ex=""; [ $V = e ] && ex="--elabuhdm"
cat $W/list | xargs -P ${BJ:-3} -I{} bash -c 'd={}; k=$(echo "$d" | md5sum | cut -c1-16); s=""
  for b in P L; do bin='"$P"'; [ $b = L ] && bin='"$L"'; o='"$W"'/o_${k}_$b.uhdm; rm -f $o
    (cd '"$R"'/$d && timeout 120 $bin dut.sv --single-unit --nobuiltin '"$ex"' -o $o >/dev/null 2>&1 </dev/null); rc=$?
    m=$( [ -s $o ] && md5sum < $o | cut -c1-12 || echo NODB); rm -f $o; s="$s $b rc=$rc $m"; done
  set -- $s; r=SAME; [ "$2 $3" != "$5 $6" ] && r=MOVE; echo "$d '"$V"'$s $r"' | sort > $O
rm -rf $W
grep -c MOVE$ $O
