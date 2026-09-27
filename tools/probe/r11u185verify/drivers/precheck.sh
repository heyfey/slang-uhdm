#!/bin/bash
# precheck.sh <out>: switch completeness -- every case of cases/ in both modes exported by pre.bin (the build of
# 312e26e2, the commit before pass 178) and compared byte for byte with law.bin under PREOFF (R11U175_OFF R11U176_OFF
# R11U178_OFF R11V178_OFF R11U181_OFF R11V181_OFF) written by grid.py as preoff.uhdm.  Cases only; fail-closed on $FENCED.
source /tmp/wt_r11u185/tools/probe/r11u185verify/drivers/env.sh || exit 2
cd /tmp/wt_r11u185/tools/probe/r11u185verify
for c in $(find cases -mindepth 2 -maxdepth 2 -type d | sort); do for el in 0 1; do
  EL=$el bash drivers/case.sh $c pre $PRE > /dev/null
  r=${c#cases/}; [ $el = 1 ] && r=${r}_el; w=/tmp/r11u185_g/$r
  a=$(md5sum < $w/pre.uhdm 2>/dev/null | cut -c1-12); b=$(md5sum < $w/preoff.uhdm 2>/dev/null | cut -c1-12)
  [ "$a" = "$b" ] && echo "SAME $r" || echo "DIFF $r pre=$a preoff=$b"
done; done > $1
echo "same=$(grep -c ^SAME $1) diff=$(grep -c ^DIFF $1)"
