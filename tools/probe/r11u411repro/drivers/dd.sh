#!/bin/bash
# r11u411_dd.sh <casedir> <binary> [ENV=..] : diff golden dump vs ours
c=$(readlink -f $1); B=$2; shift 2; h=$(md5sum $c/dut.sv | cut -c1-16)
O=/tmp/r11u411_scr/dd_$$.uhdm; rm -f $O
(cd $c && env "$@" $B dut.sv --single-unit --nobuiltin -o $O >/dev/null 2>&1)
/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump $O 2>/dev/null | sed 's/ \[[0-9]*\]//' | grep -v 'vpiFile\|^design\|^Design' | tail -n +2 > $O.dump
tail -n +2 /tmp/r11u411_gold/$h/golden.dump | diff - $O.dump; rm -f $O $O.dump
