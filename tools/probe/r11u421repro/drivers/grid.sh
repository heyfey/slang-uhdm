#!/bin/bash
# r11u421 grid: per case dir, pristine and law (case.sh lines with exit code),
# R11U421_OFF -> pristine's bytes and exit code, and the group's own switch -> pristine's bytes and exit code.
# usage: grid.sh <pristine bin> <law bin> <out>
P=$1; F=$2; OUT=$3; : > $OUT; H=$(dirname $(readlink -f $0))
D=$H/../cases
sw() { case $1 in EX) echo R11U421_EXPECTACT_OFF=1;; HS) echo R11U421_HPIPSSYSARG_OFF=1;; PB) echo R11U421_PISYSBS_OFF=1;; BF) echo R11U421_BITSDEFNOFOLD_OFF=1;; esac; }
m() { echo "$1" | sed 's/.*rc=\([0-9]*\).*md5=\([0-9a-f]*\).*/\1:\2/'; }
cd $D; for c in */*; do g=${c%/*}
 p=$(bash $H/case.sh $c $P); f=$(bash $H/case.sh $c $F)
 o=$(bash $H/case.sh $c $F R11U421_OFF=1)
 w=$(bash $H/case.sh $c $F $(sw $g))
 echo "$c | P ${p#* } | F ${f#* } | OFF=pris:$([ "$(m "$o")" = "$(m "$p")" ] && echo y || echo N) own=pris:$([ "$(m "$w")" = "$(m "$p")" ] && echo y || echo N)" >> $OUT
done
