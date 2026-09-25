#!/bin/bash
# case.sh <case dir> <mode: plain|elab> <tag> <bin> [ENV=VAL ...]
# One case: golden (pinned Surelog, check_probe's flags, + -elabuhdm in elab mode; cached per content md5),
# ours (the given binary/wrapper under the given env), rc, uhdm-cmp line count, strict verdict, record dumps.
source /tmp/wt_r11u149/tools/probe/r11u149verify/drivers/env.sh
d=$(realpath "$1"); mode=$2; tag=$3; bin=$4; shift 4
h=$(cat "$d"/*.sv "$d"/*.svh 2>/dev/null | md5sum | cut -c1-12)
w=/tmp/r11u149_cw/$(basename $(dirname $d))__$(basename $d)__$mode; mkdir -p $w; echo "$d" > $w/dir
sfl=""; ofl=""; [ "$mode" = elab ] && { sfl=-elabuhdm; ofl=--elabuhdm; }
if [ ! -s $w/golden.uhdm ] || [ "$(cat $w/golden.key 2>/dev/null)" != "$h" ]; then
  rm -rf $w/sl $w/golden.uhdm; mkdir -p $w/sl
  (cd $d && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 $sfl -o $w/sl >$w/sl.log 2>&1); echo $? > $w/sl.rc
  cp $w/sl/slpp_all/surelog.uhdm $w/golden.uhdm 2>/dev/null && echo "$h" > $w/golden.key
fi
rm -f $w/$tag.uhdm $w/$tag.rec
(cd $d && env "$@" $bin dut.sv --single-unit --nobuiltin $ofl -o $w/$tag.uhdm >/dev/null 2>$w/$tag.err); rc=$?
echo "$bin $* dut.sv --single-unit --nobuiltin $ofl" > $w/$tag.cmd
cmpn=$($UHDM_CMP $w/golden.uhdm $w/$tag.uhdm 2>&1 | wc -l)
$STRICT_CMP --max 1000000 --dump-a $w/golden.rec --dump-b $w/$tag.rec $w/golden.uhdm $w/$tag.uhdm > $w/$tag.strict 2>&1
st=$(tail -1 $w/$tag.strict)
norm(){ $UHDM_DUMP $1 2>/dev/null | sed -E 's/, id:[0-9]+//g; s/id:[0-9]+//g' | sed "s#$d/##g; s#$w/##g" | tail -n +2 | sort; }
[ -s $w/golden.ob ] && [ $w/golden.ob -nt $w/golden.uhdm ] || norm $w/golden.uhdm > $w/golden.ob
norm $w/$tag.uhdm > $w/$tag.ob; ob=$(diff $w/golden.ob $w/$tag.ob | grep -c '^[<>]')
echo "$(basename $(dirname $d))/$(basename $d) $mode $tag slrc=$(cat $w/sl.rc) rc=$rc cmp=$cmpn ob=$ob md5=$(md5sum < $w/$tag.uhdm | cut -c1-12) | $st"
