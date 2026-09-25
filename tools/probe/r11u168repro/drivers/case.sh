#!/bin/bash
# (r11u168) a case dir holds dut.sv (SystemVerilog, -sv), or dut.v (Verilog mode, no -sv), or an `args` file naming several root files (one compilation unit).
# case.sh <casedir> <slang-binary> <tag> [ENV=VAL ...]: golden (pinned Surelog, check_probe's SL_ARGS, cached by the md5
# of every file of the case) + ours + uhdm-cmp + uhdm-strictcmp.  prints: <rel> <tag> cmp=<rc> cmplines=<n> strict=<verdict> rc=<rc>
c=$(realpath $1); b=$2; t=$3; shift 3
GW=${GW:-/tmp/r11u168_g}
SURELOG=${SURELOG:-/home/heyfey/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp}
SC=${STRICT_CMP:-/tmp/r11u168_bin/uhdm-strictcmp}
SRC=dut.sv; SV=-sv; [ -f $c/dut.sv ] || { SRC=dut.v; SV=; }; [ -f $c/args ] && SRC=$(cat $c/args)   # args: several root files, one compilation unit   # a dut.v case is parsed in Verilog mode (no -sv), as the default-mode harness does for non-.sv sources
rel=$(echo $c | sed "s#.*/r11u168_cases/##; s#.*/tools/probe/r11u168repro/cases/##; s#.*/tests/probe/#probe/#; s#.*/tools/probe/#tp/#")
w=$GW/$rel; mkdir -p $w
h=$(cd $c && find . -type f ! -name LAW | sort | xargs md5sum | md5sum | cut -c1-12)
g=$w/gold/golden.uhdm
if [ ! -s $g ] || [ "$(cat $w/gold/key 2>/dev/null)" != "$h" ]; then
  rm -rf $w/gold; mkdir -p $w/gold/w
  (cd $c && $SURELOG -parse -nobuiltin -nocache $SV $SRC -mt 0 -mp 0 -o $w/gold/w > $w/gold/sl.log 2>&1)
  f=$(find $w/gold/w -name '*.uhdm' | head -1); [ -n "$f" ] && cp $f $g
  rm -rf $w/gold/w; echo $h > $w/gold/key
fi
o=$w/$t.uhdm; rm -f $o
(cd $c && env "$@" $b $SRC --single-unit --nobuiltin -o $o > $w/$t.log 2>&1); rc=$?
[ -s $g ] || { echo "$rel $t SURELOG_FAIL rc=$rc"; exit; }
[ -s $o ] || { echo "$rel $t SLANG_FAIL rc=$rc"; exit; }
$CMP $g $o > $w/$t.cmp 2>&1; cr=$?
$SC --max ${MAX:-20} --dump-a $w/$t.a.txt --dump-b $w/$t.b.txt $g $o > $w/$t.strict 2>&1
echo "$rel $t cmp=$cr cmplines=$(wc -l < $w/$t.cmp) strict=$(tail -1 $w/$t.strict | tr ' ' _) rc=$rc md5=$(md5sum < $o | cut -c1-10)"
