#!/bin/bash
# r11u308 crashscan.sh <bin> <view d|e> <out>: every dut.sv dir under tools/probe and tests/probe (the path list
# built first and filtered by $FENCED before any file is opened) run once; lists each dir whose exit code is 128 or
# more (a crash) as `<dir> rc=<n>`.  Fail-closed on $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "crashscan.sh: FENCED unset" >&2; exit 2; }
B=$1; V=$2; O=$3; [ -x "$B" ] || { echo "crashscan.sh: binary not executable" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); R=$(cd "$H/../../../.." && pwd)
FR="\\b($(echo $FENCED | tr ' ' '|'))\\b"
W=$(mktemp -d /tmp/r11u308_crash.XXXXXX)
EX=""; [ "$V" = e ] && EX="--elabuhdm"
(cd $R && find tools/probe tests/probe -name dut.sv | sort) | grep -vP "$FR" | sed 's#/dut.sv$##' > $W/list
cat $W/list | xargs -P 3 -I{} bash -c 'd={}; k=$(echo "$d" | md5sum | cut -c1-16); (cd '"$R"'/$d && timeout 120 '"$B"' dut.sv --single-unit --nobuiltin '"$EX"' -o '"$W"'/o_$k.uhdm >/dev/null 2>&1 </dev/null); rc=$?; rm -f '"$W"'/o_$k.uhdm; [ $rc -ge 128 ] && echo "$d rc=$rc"' 2>/dev/null | sort > $O
rm -rf $W
wc -l < $O
