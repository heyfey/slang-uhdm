#!/bin/bash
# r11v102: run one drop binary over every arm of the grid dirs; per arm report
# vs-FIXED SAME/DIFF, vs-PRISTINE SAME/DIFF and the nda102 score (golden,
# pristine, drop).  The dirs must already hold <arm>.{g,pris,fixv}.dump
# (grid94.sh with tags pris / fixv) plus grid94.sh and nda102.py.
# usage: BINDIR=<dir> GRIDS="<dir> <dir>" droparms94.sh <variant>
v=${1:?variant}; B=${BINDIR:?binary dir}/drop_$v.bin
LOGD=${LOGD:-/tmp}
for d in ${GRIDS:?grid dirs}; do
  cd $d
  ls *.sv | xargs -P 3 -I{} bash grid94.sh {} $v:$B > $LOGD/v11u94_dr_$v.$(basename $d).log 2>&1
  for a in $(ls *.sv | sed 's/\.sv$//'); do
    n() { sed "s#/o_${a}_$1/#/o/#" $a.$1.dump; }
    f=$(cmp -s <(n fixv) <(n $v) && echo SAME || echo DIFF)
    p=$(cmp -s <(n pris) <(n $v) && echo SAME || echo DIFF)
    s=$(python3 nda102.py $a.g.dump $a.pris.dump $a.$v.dump | tail -1)
    echo "$v $a vsFix=$f vsPris=$p $s"
  done
done
grep -h ARM $LOGD/v11u94_dr_$v.*.log | grep -vc 'slrc=0 ourrc=0 slerr=0' | sed "s/^/$v badrc=/"
