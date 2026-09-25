#!/bin/bash
# offbytes.sh [EL=1]: every case under ../cases through the pre-pass-154 build (pre154.bin, commit 5a602076)
# against the grid's ALLOFF database (law.bin with R11U154_OFF R11V154_VIDMOD_OFF R11U155_OFF): byte identity
# proves the three switches restore the pre-landing bytes.  Case-only (no corpus read).
source $(dirname $0)/env.sh
C=$(cd $(dirname $0)/../cases && pwd); T=$(mktemp -d /tmp/r11u162_offb.XXXX); n=0; same=0
ox=""; ek=""; [ "${EL:-0}" = 1 ] && { ox="--elabuhdm"; ek="_el"; }
for d in $(cd $C && ls -d */*); do
  a=/tmp/r11u162_g/$d$ek/alloff.uhdm; [ -f $a ] || continue; n=$((n+1)); rm -f $T/p.uhdm
  (cd $C/$d && /tmp/r11u162_bin/pre154.bin dut.sv --single-unit --nobuiltin $ox -o $T/p.uhdm >/dev/null 2>&1)
  if cmp -s $a $T/p.uhdm; then same=$((same+1)); else echo "DIFF $d"; fi
done; rm -rf $T; echo "offbytes$ek: $same of $n cases: ALLOFF bytes = pre154.bin bytes"
