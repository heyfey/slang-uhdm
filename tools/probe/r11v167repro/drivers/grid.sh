#!/bin/bash
# grid.sh <casedir> <slang-binary> <tag> [ENV=VAL ...]: golden (check_probe SL_ARGS, cached under $GW/<rel>/gold,
# rebuilt when dut.sv is newer) + ours + uhdm-cmp + uhdm-strictcmp. Prints <rel> <tag> cmp=<rc> cmplines=<n> strict=<v> rc=<rc>
c=$(realpath $1); b=$2; t=$3; shift 3
: ${FENCED:?FENCED unset}
for f in $FENCED; do grep -qw "$f" <<<"$c" && { echo "REFUSE fenced $c"; exit 2; }; done
GW=${GW:-/tmp/v11u167_g}
SC=${STRICT:-/tmp/v11u167_bin/strictcmp}
rel=$(echo $c | sed "s#.*/cases/##")
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
$UHDM_CMP $g $o > $w/$t.cmp 2>&1; cr=$?
$SC --max ${MAX:-20} --dump-a $w/$t.a.txt --dump-b $w/$t.b.txt $g $o > $w/$t.strict 2>&1
echo "$rel $t cmp=$cr cmplines=$(wc -l < $w/$t.cmp) strict=$(tail -1 $w/$t.strict | tr ' ' _) rc=$rc"
