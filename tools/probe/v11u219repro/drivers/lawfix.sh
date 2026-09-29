#!/bin/bash
# lawfix.sh <case tree>...: every case dir (dut.sv or args) in both views with $VB/law and $VB/$FIXBIN (default fix),
# the latter also under R11V219_OFF=1; prints <case-view> fix=same|moved off=law|DIFF (bytes against the law binary).
# Fence fail-closed.
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
export FIXBIN=${FIXBIN:-fix}
one() { c=$1; el=$2
  echo "$c" | grep -Pq "$FENCE_RE" && { echo "$c FENCED refused"; return; }
  SRC=dut.sv; [ -f $c/args ] && SRC=$(cat $c/args); ox=; [ "$el" = 1 ] && ox=--elabuhdm
  w=$(mktemp -d /tmp/v11u219_lf.XXXXXX)
  (cd $c && timeout 300 $VB/law $SRC --single-unit --nobuiltin $ox -o $w/l.uhdm >/dev/null 2>&1)
  (cd $c && timeout 300 $VB/$FIXBIN $SRC --single-unit --nobuiltin $ox -o $w/f.uhdm >/dev/null 2>&1)
  (cd $c && R11V219_OFF=1 timeout 300 $VB/$FIXBIN $SRC --single-unit --nobuiltin $ox -o $w/o.uhdm >/dev/null 2>&1)
  sm() { [ ! -e $1 ] && [ ! -e $2 ] && { echo "$3"; return; }; cmp -s $1 $2 && echo "$3" || echo "$4"; }  # no output on both sides: same
  printf "%s%s\tfix=%s\toff=%s\n" "$(echo $c | sed 's#.*/tools/probe/##')" "$([ $el = 1 ] && echo _el)" "$(sm $w/l.uhdm $w/f.uhdm same moved)" "$(sm $w/l.uhdm $w/o.uhdm law DIFF)"
  rm -rf $w; }
export -f one
for t in "$@"; do find "$(realpath $t)" \( -name dut.sv -o -name args \) -printf '%h\n'; done | sort -u | while read c; do echo "$c 0"; echo "$c 1"; done | xargs -P3 -L1 bash -c 'one $0 $1' | sort
