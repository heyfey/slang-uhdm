#!/bin/bash
# grid1.sh <casedir> <slang-binary> <tag>: golden (pinned Surelog, check_probe's SL_ARGS, built once into
# <casedir>/gold/, rebuilt when dut.sv is newer) + ours (<casedir>/<tag>.uhdm, deleted first) + uhdm-cmp + strictcmp.
# prints: case tag cmp=<rc> strict=<verdict line> rc=<slang rc>
c=$1; b=$2; t=$3
SURELOG=${SURELOG:-/home/heyfey/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp}
SC=${STRICT_CMP:-/tmp/r11u148_bin/uhdm-strictcmp}
g=$c/gold/golden.uhdm
if [ ! -s $g ] || [ $c/dut.sv -nt $g ]; then
  rm -rf $c/gold; mkdir -p $c/gold/w
  (cd $c && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o gold/w > gold/sl.log 2>&1)
  f=$(find $c/gold/w -name '*.uhdm' | head -1); [ -n "$f" ] && cp $f $g
fi
o=$c/$t.uhdm; rm -f $o
(cd $c && $b dut.sv --single-unit --nobuiltin -o $o > $c/$t.log 2>&1); rc=$?
[ -s $g ] || { echo "$(basename $c) $t SURELOG_FAIL rc=$rc"; exit; }
[ -s $o ] || { echo "$(basename $c) $t SLANG_FAIL rc=$rc"; exit; }
$CMP $g $o > $c/$t.cmp 2>&1; cr=$?
$SC --max 20 --dump-a $c/$t.a.txt --dump-b $c/$t.b.txt $g $o > $c/$t.strict 2>&1
echo "$(basename $c) $t cmp=$cr strict=$(tail -1 $c/$t.strict | tr ' ' _) head=$(head -1 $c/$t.strict | tr ' ' _) rc=$rc"
