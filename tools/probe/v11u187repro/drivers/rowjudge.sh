#!/bin/bash
# rowjudge.sh <corpus/mode/dir> <old sweep workdir> <new sweep workdir>: the first strict record and the
# order-blind record distance to golden of one corpus row-mode in two sweeps (the golden from the new sweep's cmds.txt).
source $(dirname "${BASH_SOURCE[0]}")/env.sh || exit 9
r=$1; O=$2; N=$3; echo "$r" | grep -qP "$FENCERE" && { echo FENCE; exit 4; }
gc=$(grep -o 'golden cache hit [^)]*' $N/$r/cmds.txt | awk '{print $4}'); g=$(ls $gc/*.uhdm | head -1)
w=/tmp/v11u187_rj/$r; mkdir -p $w
for t in old new; do
  wd=$O; [ $t = new ] && wd=$N
  timeout 1200 $STRICT --max 1 --dump-a $w/g.txt --dump-b $w/$t.txt $g $wd/$r/slang.uhdm > $w/$t.strict 2>&1
  echo "$t: $(head -1 $w/$t.strict) $(tail -2 $w/$t.strict | tr '\n' ' ') ob=$(python3 $(dirname "${BASH_SOURCE[0]}")/obdist.py $w/g.txt $w/$t.txt)"
done
