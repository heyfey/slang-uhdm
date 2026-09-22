#!/bin/bash
# order-blind, path-normalised, id-stripped dump diff between two sweeps' databases
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
A=$1; B=$2; REL=$3   # A=patched root, B=pristine root, REL=relative path
TA=/tmp/v11u94_attr_a.txt; TB=/tmp/v11u94_attr_b.txt
norm() { $D "$1" | sed -e 's#/tmp/v11u94_wd_[a-z]*#WD#g' -e 's/, id:[0-9]*//g' -e 's/0x[0-9a-f]*/0xPTR/g' | sort; }
norm "$A/$REL" > $TA
norm "$B/$REL" > $TB
n=$(diff $TA $TB | grep -c '^[<>]'; true)
echo "REL=$REL ORDER_BLIND_DIFF_LINES=$n"
if [ "$n" != 0 ]; then
  diff $TA $TB | grep '^[<>]' | sed 's/[0-9]\{3,\}/N/g' | sort | uniq -c | sort -rn | head -12
  echo "  -- field census over the differing lines:"
  for f in '|INT:' '|UINT:' 'vpiConstType' 'vpiSize' 'Typespec' 'int_typespec' 'vpiDecompile' 'class_defn'; do
    c=$(diff $TA $TB | grep '^[<>]' | grep -cF "$f"; true); echo "     $f = $c"
  done
fi
