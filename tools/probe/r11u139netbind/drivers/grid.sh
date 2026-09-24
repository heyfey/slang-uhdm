#!/bin/bash
# grid.sh <outdir> <binary> <case_dir>...   (r11u139)
# Per case (a dir holding dut.sv): the pinned Surelog's golden (probe flags, cached in <outdir>/gold/<case>),
# the binary's database, uhdm-cmp line count, uhdm-strictcmp verdict, and the refbind diff (which object
# every elaborated ref_obj binds, golden vs ours). Prints one line per case: case cmp strict refbind-diff-lines.
# Env: SURELOG UHDM_CMP (pinned), SC (strictcmp binary), RB (refbind binary).
out=$1; bin=$2; shift 2
SC=${SC:-/tmp/r11u139_bin/strictcmp}; RB=${RB:-/tmp/r11u139_refbind}
mkdir -p $out
for c in "$@"; do
  n=$(basename $c); g=$out/gold/$n; o=$out/$(basename $bin)/$n
  if [ ! -f $g/golden.uhdm ] || [ $c/dut.sv -nt $g/golden.uhdm ]; then
    rm -rf $g; mkdir -p $g
    (cd $c && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $g/w > $g/surelog.log 2>&1)
    f=$(find $g/w -name '*.uhdm' | head -1); [ -n "$f" ] && cp $f $g/golden.uhdm
    $RB $g/golden.uhdm > $g/refbind.txt 2>/dev/null
  fi
  rm -rf $o; mkdir -p $o
  (cd $c && $bin dut.sv --single-unit --nobuiltin -o $o/ours.uhdm > $o/slang.log 2>&1; echo "rc=$?" > $o/rc)
  if [ ! -f $g/golden.uhdm ]; then echo "$n SURELOG_FAIL"; continue; fi
  if [ ! -f $o/ours.uhdm ]; then echo "$n SLANG_FAIL $(cat $o/rc)"; continue; fi
  $UHDM_CMP $g/golden.uhdm $o/ours.uhdm > $o/cmp.txt 2>&1
  cl=$(grep -c . $o/cmp.txt; true)
  $SC --max 20 --dump-a $o/strict.a --dump-b $o/strict.b $g/golden.uhdm $o/ours.uhdm > $o/strict.txt 2>&1
  st=$(tail -1 $o/strict.txt | awk '{print $1"/"$2}')
  $RB $o/ours.uhdm > $o/refbind.txt 2>/dev/null
  diff $g/refbind.txt $o/refbind.txt > $o/refbind.diff
  rl=$(grep -c '^[<>]' $o/refbind.diff; true)
  echo "$n cmp=$cl strict=$st rbdiff=$rl"
done
