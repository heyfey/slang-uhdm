#!/bin/bash
# v11u425 case.sh <casedir> <binary> [ENV=VAL...] (optional TOP file names the top module for both tools):
# golden (cached by md5 of dut.sv+TOP) + ours; prints rc, uhdm-cmp lines, dump-diff distance, dump md5, strict verdict
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
SC=${STRICTCMP:-/tmp/v11u425_bin/strictcmp}
for t in $SL $CMP $DUMP $SC; do [ -x "$t" ] || { echo "MISSING TOOL $t"; exit 9; }; done
c=$(readlink -f $1); B=$2; shift 2; [ -x "$B" ] || { echo "MISSING BIN $B"; exit 9; }
TS=""; TL=""; [ -f $c/TOP ] && { TS="--top-module $(cat $c/TOP)"; TL="--top $(cat $c/TOP)"; }
h=$(cat $c/dut.sv $c/TOP 2>/dev/null | md5sum | cut -c1-16); G=/tmp/v11u425_gold2/$h
if [ ! -f $G/done ]; then mkdir -p $G; (cd $c && $SL -parse -nobuiltin -nocache -sv $TS dut.sv -mt 0 -mp 0 -o $G/out >$G/log 2>&1); cp $G/out/slpp_all/surelog.uhdm $G/golden.uhdm 2>/dev/null; [ -f $G/golden.uhdm ] && $DUMP $G/golden.uhdm 2>/dev/null | sed 's/ \[[0-9]*\]//' | grep -v 'vpiFile\|^design\|^Design' > $G/golden.dump; touch $G/done; fi
tag=$(echo "$c $B $*" | md5sum | cut -c1-12)
O=/tmp/v11u425_scr/o_$tag.uhdm; rm -f $O $O.dump
(cd $c && env "$@" $B dut.sv $TL --single-unit --nobuiltin -o $O >/tmp/v11u425_scr/l_$tag.log 2>&1); rc=$?
ge=$(grep -c '^\[ERR:\|^\[FAT:' $G/log 2>/dev/null)
if [ ! -f $G/golden.uhdm ]; then echo "$(basename $c) rc=$rc NO_GOLDEN"; exit; fi
if [ ! -f $O ]; then echo "$(basename $c) rc=$rc NO_DB gerr=$ge $(tail -1 /tmp/v11u425_scr/l_$tag.log)"; exit; fi
n=$($CMP $G/golden.uhdm $O 2>&1 | wc -l); s=$($SC $G/golden.uhdm $O 2>&1 | tail -1)
$DUMP $O 2>/dev/null | sed 's/ \[[0-9]*\]//' | grep -v 'vpiFile\|^design\|^Design' > $O.dump
d=$(diff $G/golden.dump $O.dump | grep -c '^[<>]')
echo "$(basename $c) rc=$rc gerr=$ge cmp=$n away=$d md5=$(md5sum < $O | cut -c1-8) | $s"
