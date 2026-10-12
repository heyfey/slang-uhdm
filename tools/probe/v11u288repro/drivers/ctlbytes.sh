#!/bin/bash
# v11u288 ctlbytes.sh <out> <binA> <binB> [root]: the byte control. Every dut.sv case dir under tools/probe (path list
# built first and filtered by $FENCED before any file is opened), both views, run on both binaries; one line per
# case-view: <case> <view> rcA rcB md5A md5B. Fail-closed on $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "ctlbytes.sh: FENCED unset" >&2; exit 2; }
out=$1; A=$2; B=$3; H=$(cd "$(dirname "$0")" && pwd); ROOT=${4:-$(cd "$H/../.." && pwd)}
[ -x "$A" ] && [ -x "$B" ] || { echo "ctlbytes.sh: binary not executable" >&2; exit 2; }
T=/tmp/v11u288_ctl.$$; mkdir -p $T; : > $out
one() { d=$1; v=$2; ex=""; [ $v = e ] && ex="--elabuhdm"; k=$(echo "$d$v" | md5sum | cut -c1-12)
  rm -f $T/$k.a $T/$k.b
  (cd $d && timeout 300 $A dut.sv --single-unit --nobuiltin $ex -o $T/$k.a >/dev/null 2>&1 </dev/null); ra=$?
  (cd $d && timeout 300 $B dut.sv --single-unit --nobuiltin $ex -o $T/$k.b >/dev/null 2>&1 </dev/null); rb=$?
  ma=$( [ -s $T/$k.a ] && md5sum < $T/$k.a | cut -c1-12 || echo none); mb=$( [ -s $T/$k.b ] && md5sum < $T/$k.b | cut -c1-12 || echo none)
  rm -f $T/$k.a $T/$k.b; echo "${d#$ROOT/} $v $ra $rb $ma $mb" >> $out; }
find $ROOT -name dut.sv -type f | xargs -n1 dirname | sort -u | grep -vwE "$(echo $FENCED | tr ' ' '|')" > $T/list
for d in $(cat $T/list); do for v in d e; do one $d $v & while [ $(jobs -r | wc -l) -ge 3 ]; do sleep 0.05; done; done; done
wait; rm -rf $T; sort -o $out $out
