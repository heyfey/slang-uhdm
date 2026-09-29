#!/bin/bash
# r11u215: byte-control MOVER scan (no golden needed): export every listed case dir with the pristine and the law
# binary (both views: parse form, ELAB=1 --elabuhdm), print `<case> MOVED` for every database that differs.  The movers
# are then judged with judge.sh.  Fence fail-closed (env.sh; a fenced name in a path is refused).
# usage: ctlmove.sh <list of absolute case dirs> <law binary name in $B>
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
T=/tmp/r11u215_ctlmv${ELAB:+_elab}; mkdir -p $T
one() { c=$1; for f in $FENCED; do grep -qw "$f" <<< "$c" && { echo "$c FENCED"; return; }; done
  k=$(echo "$c" | md5sum | cut -c1-10); o=$T/$k; mkdir -p $o; E=; [ -n "$ELAB" ] && E=--elabuhdm
  SRC=dut.sv; [ -f "$c/args" ] && SRC=$(cat "$c/args"); [ ! -f "$c/args" ] && [ -f "$c/files" ] && SRC=$(cat "$c/files" | tr "\n" " ")
  for b in pris.bin $LB; do rm -f $o/$b.uhdm; ( cd $c && $B/$b $SRC --single-unit --nobuiltin $E -o $o/$b.uhdm > /dev/null 2>&1 ); done
  if [ ! -s $o/pris.bin.uhdm ] && [ ! -s $o/$LB.uhdm ]; then echo "$c NODB"; return; fi
  cmp -s $o/pris.bin.uhdm $o/$LB.uhdm || echo "$c MOVED"; }
export -f one; export T B LB=$2 ELAB FENCED
cat $1 | xargs -P2 -I{} bash -c 'one {}' | sort
echo "LISTED $(wc -l < $1)"
