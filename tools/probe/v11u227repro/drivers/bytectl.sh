#!/bin/bash
# (v11u227) bytectl.sh <out> <binA> <binB> <root>...: every case directory (dut.sv / dut.v, or an args file) under the
# roots, both views, run with binA and binB (harness arguments --single-unit --nobuiltin [--elabuhdm]); one line per
# case-view `<dir> <view> <md5A> <md5B> <rcA> <rcB> same|MOVED`. Binary runs only (no golden); fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "bytectl: FENCED" >&2; exit 2; }
O=$1; A=$2; Bb=$3; shift 3
[ -x "$A" ] && [ -x "$Bb" ] || { echo "bytectl: binaries" >&2; exit 2; }
T=${BYTECTL_TMP:?export BYTECTL_TMP}; mkdir -p $T
export A Bb T FENCED
one() { c=$1; el=$2
  for n in $FENCED; do echo "$c" | grep -qw "$n" && { echo "$c fenced-refused"; return; }; done
  SRC=dut.sv; [ -f $c/dut.sv ] || SRC=dut.v; [ -f $c/args ] && SRC=$(cat $c/args)
  ox=""; [ $el = 1 ] && ox="--elabuhdm"
  k=$(echo "$c$el" | md5sum | cut -c1-16)
  rm -f $T/$k.a $T/$k.b
  (cd $c && timeout 300 "$A" $SRC --single-unit --nobuiltin $ox -o $T/$k.a > /dev/null 2>&1); ra=$?
  (cd $c && timeout 300 "$Bb" $SRC --single-unit --nobuiltin $ox -o $T/$k.b > /dev/null 2>&1); rb=$?
  ma=$(md5sum < $T/$k.a 2>/dev/null | cut -c1-12); mb=$(md5sum < $T/$k.b 2>/dev/null | cut -c1-12)
  echo "$c $el ${ma:-none} ${mb:-none} $ra $rb $([ "$ma" = "$mb" ] && echo same || echo MOVED)"; rm -f $T/$k.a $T/$k.b; }
export -f one
for r in "$@"; do find $r \( -name dut.sv -o -name dut.v \) -printf '%h\n'; done | sort -u | while read c; do echo "$c 0"; echo "$c 1"; done | xargs -P3 -L1 bash -c 'one $0 $1' > $O
echo "$(wc -l < $O) case-views; moved $(grep -c ' MOVED$' $O); rc differs $(awk '$5!=$6' $O | wc -l)"
