#!/bin/bash
# v11u287 attr.sh <grid file> <out>: every P->F mover case-view rerun on the fix with each R11U287 law switch off
# (and the loop refinement's); the switch that gives back pristine's md5 names the law.
H=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$H/../../../.." && pwd); D=$REPO/tools/probe/r11u287repro/drivers
. $D/env.sh || exit 2
python3 $H/gridsum.py $1 P F | grep -v '^P->' | awk '{print $1}' | while read rel; do
  el=0; r=$rel; case $rel in *_el) el=1; r=${rel%_el};; esac
  case $r in tp/*) c=$REPO/tools/probe/${r#tp/};; *) c=$REPO/tools/probe/r11u287repro/cases/$r;; esac
  for sw in IFARRINTTS DEFGENSELNAME PVRECVBODYTS PVFLATTS GENCASHARE EVALKEEP LOOPONCE; do echo "$el $c A_$sw $B/fix R11U287_${sw}_OFF=1"; done
done | xargs -P 3 -L 1 bash -c 'EL=$0 '"$D"'/case.sh $1 $2 $3 $4' > $2 2>&1
