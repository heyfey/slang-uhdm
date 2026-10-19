#!/bin/bash
# r11u411 case.sh <casedir> <binary> [ENV=VAL...] : golden (cached by md5 of dut.sv) + ours; prints rc, cmp lines, strict verdict, dump md5
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
SC=/tmp/r11u411_bin/strictcmp
c=$(readlink -f $1); B=$2; shift 2
h=$(md5sum $c/dut.sv | cut -c1-16); G=/tmp/r11u411_gold/$h
if [ ! -f $G/golden.uhdm ]; then mkdir -p $G; (cd $c && $SL -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $G/out >$G/log 2>&1); cp $G/out/slpp_all/surelog.uhdm $G/golden.uhdm 2>/dev/null; [ -f $G/golden.uhdm ] && $DUMP $G/golden.uhdm 2>/dev/null | sed 's/ \[[0-9]*\]//' | grep -v 'vpiFile\|^design\|^Design' > $G/golden.dump; fi
tag=$(echo "$c $B $*" | md5sum | cut -c1-12)
O=/tmp/r11u411_scr/o_$tag.uhdm; rm -f $O
(cd $c && env "$@" $B dut.sv --single-unit --nobuiltin -o $O >/tmp/r11u411_scr/l_$tag.log 2>&1); rc=$?
if [ ! -f $G/golden.uhdm ]; then echo "$(basename $c) rc=$rc NO_GOLDEN"; exit; fi
if [ ! -f $O ]; then echo "$(basename $c) rc=$rc NO_DB $(tail -1 /tmp/r11u411_scr/l_$tag.log)"; exit; fi
n=$($CMP $G/golden.uhdm $O 2>&1 | wc -l); s=$($SC $G/golden.uhdm $O 2>&1 | tail -1)
$DUMP $O 2>/dev/null | sed 's/ \[[0-9]*\]//' | grep -v 'vpiFile\|^design\|^Design' > $O.dump
d=$(diff $G/golden.dump $O.dump | grep -c '^[<>]')
echo "$(basename $c) rc=$rc cmp=$n away=$d md5=$(md5sum < $O | cut -c1-8) | $s"
