#!/bin/bash
# v11u280 bytectl.sh <out.txt> <pristine bin> <law bin> <repro dir>...: byte-only controls (no golden).
# Every case dir (dut.sv / dut.v) under the named tools/probe repro dirs, both views, on both binaries;
# one line per case-view: <case> <view> rcP=.. rcL=.. same|MOVED|nodb (nodb: neither binary wrote a database).  The path list is built first and
# filtered by $FENCED (word boundary) before any case is opened.  Movers are then judged with case.sh
# and away.sh.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "bytectl.sh: FENCED unset" >&2; exit 2; }
H=$(cd "$(dirname "$0")/../.." && pwd); out=$1; P=$2; L=$3; shift 3; : > $out
[ -x "$P" ] && [ -x "$L" ] || { echo "bytectl.sh: binary not executable" >&2; exit 2; }
fre=$(echo $FENCED | tr ' ' '|')
T=${V280_OUT:-/tmp/v11u280_caseout}/bytectl; mkdir -p $T
export P L T
for d in "$@"; do find $H/$d \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##'; done | sort -u | grep -vwE "$fre" |
  while read c; do for v in d e; do echo "$c $v"; done; done |
  xargs -P ${J:-4} -L 1 bash -c '
    c=$0; v=$1; k=$(echo "$c $v" | md5sum | cut -c1-16); ex=""; [ $v = e ] && ex="--elabuhdm"
    f=dut.sv; [ -f $c/dut.sv ] || f=dut.v
    rm -f $T/$k.p $T/$k.l
    (cd $c && $P $f --single-unit --nobuiltin $ex -o $T/$k.p >/dev/null 2>&1 </dev/null); rp=$?
    (cd $c && $L $f --single-unit --nobuiltin $ex -o $T/$k.l >/dev/null 2>&1 </dev/null); rl=$?
    if [ ! -e $T/$k.p ] && [ ! -e $T/$k.l ]; then s=nodb; else s=same; cmp -s $T/$k.p $T/$k.l || s=MOVED; fi
    rm -f $T/$k.p $T/$k.l
    echo "$(echo $c | sed "s#.*/tools/probe/##") $v rcP=$rp rcL=$rl $s"' >> $out
