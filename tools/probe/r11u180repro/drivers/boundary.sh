#!/bin/bash
# boundary.sh <law binary> <out.txt> : every case dir under tools/probe (a dut.sv, or a `files` list) exported by the
# pristine and the law binary (`--single-unit --nobuiltin`, the probe harness's arguments); prints every case whose
# database bytes differ (MOVER) and the counts. A fenced name anywhere in the path is skipped (fail closed).
set -u; . /tmp/wt_r11u180/tools/probe/r11u180repro/drivers/env.sh || exit 2
L=$1; OUT=$2; re=$(echo $FENCED | sed 's/ /|/g')
cd /tmp/wt_r11u180/tools/probe
find . -name dut.sv -printf '%h\n' | sort -u | grep -Evw "($re)" | grep -v '^./r11u180repro' > /tmp/r11u180_scr/bnd.list
one() {
  d=$1; k=$(echo $d | sed 's|^\./||; s|/|__|g'); o=/tmp/r11u180_bnd/$k; mkdir -p $o
  F=$( [ -f $d/files ] && cat $d/files || echo dut.sv )
  (cd $d && timeout 120 /tmp/r11u180_bin/pris.bin $F --single-unit --nobuiltin -o $o/p.uhdm >/dev/null 2>&1 </dev/null); rp=$?
  (cd $d && timeout 120 $L $F --single-unit --nobuiltin -o $o/l.uhdm >/dev/null 2>&1 </dev/null); rl=$?
  if [ ! -s $o/p.uhdm ] && [ ! -s $o/l.uhdm ]; then echo "NODB $d rp=$rp rl=$rl";
  elif cmp -s $o/p.uhdm $o/l.uhdm; then echo "SAME $d"; else echo "MOVER $d rp=$rp rl=$rl"; fi
  rm -f $o/p.uhdm $o/l.uhdm
}
export -f one; export L
xargs -a /tmp/r11u180_scr/bnd.list -P 4 -I{} bash -c 'one {}' | sort > $OUT
echo "listed $(wc -l < /tmp/r11u180_scr/bnd.list) processed $(wc -l < $OUT) movers $(grep -c ^MOVER $OUT) nodb $(grep -c ^NODB $OUT)"
