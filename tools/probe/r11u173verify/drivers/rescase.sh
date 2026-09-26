#!/bin/bash
# rescase.sh <casedir> [binary]: an earlier pass's case (read in place, never copied) judged at the base:
# golden with check_probe's Surelog arguments cached under /tmp/r11u173_gres/<pass>/<rel>, ours with
# --single-unit --nobuiltin, uhdm-cmp line count, the strict verdict.  Fail-closed on $FENCED.
[ -n "$FENCED" ] || { echo "rescase.sh: source drivers/env.sh" >&2; exit 2; }
c=$(realpath $1); b=${2:-$LAW}
for n in $FENCED; do echo "$c" | grep -qw "$n" && { echo "rescase.sh: fenced path refused" >&2; exit 2; }; done
rel=$(echo $c | sed 's#.*/tools/probe/##')
w=/tmp/r11u173_gres/$rel; mkdir -p $w
h=$(cat $c/dut.sv | md5sum | cut -c1-12); g=$w/gold_$h/golden.uhdm
if [ ! -s $g ] && [ ! -e $w/gold_$h/failed ]; then
  mkdir -p $w/gold_$h/w
  (cd $c && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $w/gold_$h/w > $w/gold_$h/sl.log 2>&1)
  f=$(find $w/gold_$h/w -name '*.uhdm' | head -1); [ -n "$f" ] && cp $f $g || touch $w/gold_$h/failed; rm -rf $w/gold_$h/w
fi
o=$w/$(basename $b).uhdm; rm -f $o
(cd $c && timeout 300 $b dut.sv --single-unit --nobuiltin -o $o > $w/$(basename $b).log 2>&1); rc=$?
[ -s $g ] || { echo "$rel SURELOG_FAIL rc=$rc"; exit 0; }
[ -s $o ] || { echo "$rel SLANG_FAIL rc=$rc"; exit 0; }
$UHDM_CMP $g $o > $o.cmp 2>&1; cr=$?
$STRICT_CMP --max 100000 $g $o > $o.strict 2>&1
echo "$rel cmp=$cr cmplines=$(wc -l < $o.cmp) strict=$(tail -1 $o.strict | tr ' ' _) $(grep -o 'objects_differing=[0-9]*' $o.strict) rc=$rc"
