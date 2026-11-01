#!/bin/bash
# probedump.sh <law probe workdir> <control probe workdir> <out>: path-normalized
# uhdm-dump comparison of every probe database (raw bytes embed the workdir).
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || { echo "no uhdm-dump"; exit 2; }
A=$1; B=$2; O=$3; : > $O; n=0; m=0
norm() { sed -e 's|/tmp/[A-Za-z0-9_]*/probe|WD|g' -e 's|/tmp/wt_r11u459/tests/probe|TP|g' -e 's|/home/heyfey/git-repos/slang-uhdm/tests/probe|TP|g'; }
for f in $(cd $A && ls *.uhdm); do
  n=$((n+1))
  if ! cmp -s <(nice -n 19 $D $A/$f 2>/dev/null | norm) <(nice -n 19 $D $B/$f 2>/dev/null | norm); then
    m=$((m+1)); echo "MOVER $f" >> $O
  fi
done
echo "probe dump movers: $m of $n" >> $O
