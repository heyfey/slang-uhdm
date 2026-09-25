#!/bin/bash
# grid1.sh <casedir> <slang-binary> <tag> [outroot]: golden (pinned Surelog, check_probe's SL_ARGS,
# built once into <outroot>/<class>/<case>/gold/, rebuilt when dut.sv is newer) + ours (<tag>.uhdm,
# deleted first) + uhdm-cmp + uhdm-strictcmp. Nothing is written under <casedir>.
# prints: case tag cmp=<rc> strict=<verdict line> head=<first head line> rc=<slang rc>
c=$(cd "$1" && pwd); b=$2; t=$3; R=${4:-/tmp/r11u151_g}
SURELOG=${SURELOG:-/home/heyfey/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp}
SC=${STRICT_CMP:-/tmp/r11u151_bin/strictcmp}
w=$R/$(basename $(dirname $c))/$(basename $c); mkdir -p $w
g=$w/gold/golden.uhdm
if [ ! -s $g ] || [ $c/dut.sv -nt $g ]; then
  rm -rf $w/gold; mkdir -p $w/gold/w
  (cd $c && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $w/gold/w > $w/gold/sl.log 2>&1)
  f=$(find $w/gold/w -name '*.uhdm' | head -1); [ -n "$f" ] && cp $f $g
fi
o=$w/$t.uhdm; rm -f $o
(cd $c && $b dut.sv --single-unit --nobuiltin -o $o > $w/$t.log 2>&1); rc=$?
[ -s $g ] || { echo "$(basename $c) $t SURELOG_FAIL rc=$rc"; exit; }
[ -s $o ] || { echo "$(basename $c) $t SLANG_FAIL rc=$rc"; exit; }
$CMP $g $o > $w/$t.cmp 2>&1; cr=$?
$SC --max 20 --dump-a $w/$t.a.txt --dump-b $w/$t.b.txt $g $o > $w/$t.strict 2>&1
echo "$(basename $c) $t cmp=$cr strict=$(tail -1 $w/$t.strict | tr ' ' _) head=$(head -1 $w/$t.strict | tr ' ' _) rc=$rc"
