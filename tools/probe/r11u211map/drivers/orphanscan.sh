#!/bin/bash
# r11u211: the cross-binary orphan scan (pass 206's R1): every dut.sv case dir under the given tools/probe roots run by
# the pristine binary and by a second binary ($OTHER) with the probe command line; a case whose bytes differ while its
# raw uhdm-dump (paths normalised) is identical is an orphan-bearing database (unreachable bytes only).
# usage: orphanscan.sh <out dir> <root>...     (fenced names refused, fail closed)
. "$(dirname "$0")/env.sh"
O=$1; shift; mkdir -p $O; OTHER=${OTHER:-slang-uhdm.lawA205}
for r in "$@"; do find /tmp/wt_r11u211/$r -name dut.sv -printf '%h\n'; done | sort > $O/dirs.txt
n=0; nb=0; no=0; nd=0
while read -r d <&3; do
  echo "$d" | grep -Pq "$FENCERE" && { echo "FENCED refused"; continue; }
  t=$(echo ${d#/tmp/wt_r11u211/} | tr '/' '_'); n=$((n+1))
  for b in slang-uhdm $OTHER; do rm -f $O/$t.$b.uhdm; (cd $d && timeout 300 /tmp/r11u211_bin/$b dut.sv --single-unit --nobuiltin -o $O/$t.$b.uhdm > /dev/null 2>&1 < /dev/null); done
  [ -s $O/$t.slang-uhdm.uhdm ] && [ -s $O/$t.$OTHER.uhdm ] || { nd=$((nd+1)); continue; }
  cmp -s $O/$t.slang-uhdm.uhdm $O/$t.$OTHER.uhdm && { rm -f $O/$t.*.uhdm; continue; }
  nb=$((nb+1))
  a=$($UHDM_DUMP $O/$t.slang-uhdm.uhdm 2>/dev/null | sed "s#$O/$t.slang-uhdm.uhdm#DB#g" | md5sum | cut -c1-12)
  b=$($UHDM_DUMP $O/$t.$OTHER.uhdm 2>/dev/null | sed "s#$O/$t.$OTHER.uhdm#DB#g" | md5sum | cut -c1-12)
  if [ "$a" = "$b" ]; then no=$((no+1)); echo "ORPHAN-ONLY ${d#/tmp/wt_r11u211/} first byte $(cmp $O/$t.slang-uhdm.uhdm $O/$t.$OTHER.uhdm | awk '{print $5}' | tr -d ,)"; else echo "DUMP-MOVER ${d#/tmp/wt_r11u211/}"; fi
done 3< $O/dirs.txt
echo "cases $n; no database in one binary $nd; byte movers $nb; of which dump-identical (orphan-only) $no"
