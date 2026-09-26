#!/bin/bash
# grid.sh <casedir> <binary> <tag> [ENV=VAL ...]; ELAB=1 for -elabuhdm/--elabuhdm
ARGS=("$@"); source /tmp/v11u178_env.sh; set -- "${ARGS[@]}"
c=$(realpath $1); b=$2; t=$3; shift 3
if echo "$c" | grep -qE "$FENCED_RE"; then echo "FENCED refuse"; exit 2; fi
GW=${GW:-/tmp/v11u178_g}
rel=$(echo $c | sed -e "s#.*/r11u178repro/cases/#impl/#" -e "s#.*/r11v178repro/cases/#v/#" -e "s#.*/r11u175uvm/cases/#u175/#" -e "s#.*/tests/probe/#probe/#"); [ -n "${ELAB:-}" ] && rel=$rel.elab
w=$GW/$rel; mkdir -p $w
g=$w/gold/golden.uhdm
if [ ! -s $g ] || [ $c/dut.sv -nt $g ]; then
  rm -rf $w/gold; mkdir -p $w/gold/w
  (cd $c && $SURELOG -parse -nobuiltin -nocache -sv ${ELAB:+-elabuhdm} dut.sv -mt 0 -mp 0 -o $w/gold/w > $w/gold/sl.log 2>&1)
  f=$(find $w/gold/w -name '*.uhdm' | head -1); [ -n "$f" ] && cp $f $g
  rm -rf $w/gold/w
fi
o=$w/$t.uhdm; rm -f $o
(cd $c && env "$@" $b ${ELAB:+--elabuhdm} dut.sv --single-unit --nobuiltin -o $o > $w/$t.log 2>&1); rc=$?
[ -s $g ] || { echo "$rel $t SURELOG_FAIL rc=$rc"; exit; }
[ -s $o ] || { echo "$rel $t SLANG_FAIL rc=$rc"; exit; }
$UHDM_CMP $g $o > $w/$t.cmp 2>&1; cr=$?
$STRICT --max ${MAX:-20} --dump-a $w/$t.a.txt --dump-b $w/$t.b.txt $g $o > $w/$t.strict 2>&1
echo "$rel $t cmp=$cr cmplines=$(wc -l < $w/$t.cmp) strict=$(tail -1 $w/$t.strict | tr ' ' _) rc=$rc"
