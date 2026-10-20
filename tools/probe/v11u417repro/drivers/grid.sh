#!/bin/bash
# v11u417 grid.sh <casesdir> <out> : pristine, law, R11U417_OFF, own switch per case
P=/tmp/v11u417_bin/pristine; F=${LAWBIN:-/tmp/v11u417_bin/law}; D=$1; OUT=$2; : > $OUT
H=/tmp/v11u417_drv
sw() { case $1 in VC|FC) echo R11U417_FOREACHCLASS_OFF;; VT|FT) echo R11U417_FOREACHTD_OFF;; VH|HP) echo R11U417_HSPARENBND_OFF;; *) echo R11U417_NONE_OFF;; esac; }
m() { echo "$1" | sed 's/.*rc=\([0-9]*\).*md5=\([0-9a-f]*\).*/\1:\2/'; }
cd $D; for c in ${CASES:-*/*}; do g=${c%/*}
 p=$(bash $H/case.sh $c $P); f=$(bash $H/case.sh $c $F)
 o=$(bash $H/case.sh $c $F R11U417_OFF=1)
 w=$(bash $H/case.sh $c $F $(sw $g)=1)
 echo "$c | P ${p#* } | F ${f#* } | OFF=pris:$([ "$(m "$o")" = "$(m "$p")" ] && echo y || echo N) own=pris:$([ "$(m "$w")" = "$(m "$p")" ] && echo y || echo N)" >> $OUT
done
