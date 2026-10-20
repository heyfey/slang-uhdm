#!/bin/bash
# grid.sh <pristine> <law> <out> <case dirs...>
P=$1; F=$2; OUT=$3; shift 3; : > $OUT; H=/tmp/v11u421_drv
sw() { case $1 in VE|EX) echo R11U421_EXPECTACT_OFF=1;; VH|HS) echo R11U421_HPIPSSYSARG_OFF=1;; VP|PB) echo R11U421_PISYSBS_OFF=1;; VB|BF) echo R11U421_BITSDEFNOFOLD_OFF=1;; esac; }
m() { echo "$1" | sed 's/.*rc=\([0-9]*\).*md5=\([0-9a-f]*\).*/\1:\2/'; }
for c in "$@"; do g=$(basename $(dirname $c))
 up=$(cd $c && timeout 60 $HOME/.local/bin/slang dut.sv --single-unit -q >/dev/null 2>&1; echo $?)
 p=$(bash $H/case.sh $c $P); f=$(bash $H/case.sh $c $F)
 o=$(bash $H/case.sh $c $F R11U421_OFF=1)
 w=$(bash $H/case.sh $c $F $(sw $g))
 echo "$g/$(basename $c) | slang=$up | P ${p#* } | F ${f#* } | OFF=pris:$([ "$(m "$o")" = "$(m "$p")" ] && echo y || echo N) own=pris:$([ "$(m "$w")" = "$(m "$p")" ] && echo y || echo N)" >> $OUT
done
