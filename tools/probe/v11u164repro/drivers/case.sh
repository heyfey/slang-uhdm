#!/bin/bash
# v11u164 case driver: <casedir> <slang-binary> <tag> [ENV=VAL ...]
# golden (pinned Surelog, check_probe's SL_ARGS) + ours + uhdm-cmp + uhdm-strictcmp
c=$(realpath $1); b=$2; t=$3; shift 3
GW=${GW:-/tmp/v11u164_g}
SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
SC=/tmp/v11u164_bin/uhdm-strictcmp
rel=$(echo $c | sed "s#.*/v11u164_cases/#mine/#; s#.*/tools/probe/r11u164repro/cases/#r164/#; s#.*/tests/probe/#probe/#; s#.*/tools/probe/#tp/#")
w=$GW/$rel; mkdir -p $w
g=$w/gold/golden.uhdm
if [ ! -s $g ] || [ $c/dut.sv -nt $g ]; then
  rm -rf $w/gold; mkdir -p $w/gold/w
  (cd $c && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $w/gold/w > $w/gold/sl.log 2>&1)
  f=$(find $w/gold/w -name '*.uhdm' | head -1); [ -n "$f" ] && cp $f $g
  rm -rf $w/gold/w
fi
o=$w/$t.uhdm; rm -f $o
(cd $c && env "$@" $b dut.sv --single-unit --nobuiltin -o $o > $w/$t.log 2>&1); rc=$?
[ -s $g ] || { echo "$rel $t SURELOG_FAIL rc=$rc"; exit; }
[ -s $o ] || { echo "$rel $t SLANG_FAIL rc=$rc"; exit; }
$CMP $g $o > $w/$t.cmp 2>&1; cr=$?
$SC --max ${MAX:-20} --dump-a $w/$t.a.txt --dump-b $w/$t.b.txt $g $o > $w/$t.strict 2>&1
echo "$rel $t cmp=$cr cmplines=$(wc -l < $w/$t.cmp) strict=$(tail -1 $w/$t.strict | tr ' ' _) rc=$rc md5=$(md5sum < $o | cut -c1-8)"
