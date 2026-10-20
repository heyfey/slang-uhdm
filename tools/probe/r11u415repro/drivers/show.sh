#!/bin/bash
# r11u415 show.sh <casedir> <binary> [ENV=VAL...]: the strict records (--max 8) and the dump diff of a case run by case.sh
c=$(readlink -f $1); B=$2; shift 2
h=$(cat $c/dut.sv $c/TOP 2>/dev/null | md5sum | cut -c1-16); G=/tmp/r11u415_gold/$h
tag=$(echo "$c $B $*" | md5sum | cut -c1-12); O=/tmp/r11u415_scr/o_$tag.uhdm
[ -f $O ] || bash $(dirname $0)/case.sh $c $B "$@" >/dev/null
${STRICTCMP:-/tmp/r11u415_bin/strictcmp} --max 8 $G/golden.uhdm $O 2>&1 | tail -30
diff $G/golden.dump $O.dump | head -${N:-40}
