#!/bin/bash
# case.sh <casedir> [binary] : golden (cached by md5 of dut.sv) + ours; prints rc, cmp lines, strict verdict
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
SC=/tmp/r11u409_bin/strictcmp
c=$(readlink -f $1); B=${2:-${LAWBIN:-/tmp/r11u409_bin/pristine}}
h=$(md5sum $c/dut.sv | cut -c1-16); G=/tmp/r11u409_gold/$h
if [ ! -f $G/golden.uhdm ]; then mkdir -p $G; (cd $c && $SL -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $G/out >$G/log 2>&1); cp $G/out/slpp_all/surelog.uhdm $G/golden.uhdm 2>/dev/null; fi
O=/tmp/r11u409_scr/o_$(echo $c | md5sum | cut -c1-12)_$(basename $B).uhdm; rm -f $O
(cd $c && $B dut.sv --single-unit --nobuiltin -o $O >/tmp/r11u409_scr/last.log 2>&1); rc=$?
if [ ! -f $O ]; then echo "$(basename $c) rc=$rc NO_DB $(tail -1 /tmp/r11u409_scr/last.log)"; exit; fi
n=$($CMP $G/golden.uhdm $O 2>&1 | wc -l); s=$($SC $G/golden.uhdm $O 2>&1 | tail -1)
echo "$(basename $c) rc=$rc cmp=$n $s"
