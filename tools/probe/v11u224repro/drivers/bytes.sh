#!/bin/bash
# v11u224: wide byte control. bytes.sh <root> <outfile>: every case dir under <root> (dut.sv / dut.v / args), both
# views, $B/pristine.bin vs $B/$LAWBIN (default law.bin): one line per case-view "<dir> <view> same|moved|rcdiff rcP rcL".
# No golden, no judge; fail-closed on $FENCED (a path holding a fenced name, word-bounded, is skipped unread).
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
export LAWBIN=${LAWBIN:-law.bin} W=$S/bytes; mkdir -p $W
one() { c=$1; el=$2
  for n in $FENCED; do echo "$c" | grep -qw "$n" && { echo "$c $el FENCED_SKIP"; return; }; done
  SRC=dut.sv; [ -f $c/dut.sv ] || SRC=dut.v; [ -f $c/args ] && SRC=$(cat $c/args)
  ox=""; [ $el = 1 ] && ox=--elabuhdm
  t=$W/$(echo $c | md5sum | cut -c1-16)_$el; rm -f $t.p $t.l
  (cd $c && timeout 180 $B/pristine.bin $SRC --single-unit --nobuiltin $ox -o $t.p >/dev/null 2>&1); rp=$?
  (cd $c && timeout 180 $B/$LAWBIN $SRC --single-unit --nobuiltin $ox -o $t.l >/dev/null 2>&1); rl=$?
  if [ $rp != $rl ]; then v=rcdiff; elif cmp -s $t.p $t.l; then v=same; else v=moved; fi
  echo "$c $el $v $rp $rl"; rm -f $t.p $t.l; }
export -f one
find ${1:?root} \( -name dut.sv -o -name dut.v -o -name args \) -printf '%h\n' | sort -u | while read c; do echo "$c 0"; echo "$c 1"; done | xargs -P${BJ:-3} -L1 bash -c 'one $0 $1' > ${2:?out}
