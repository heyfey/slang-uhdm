#!/bin/bash
# r11u417 grid: per case dir, pristine and final (case.sh lines with exit code),
# R11U417_OFF -> pristine's bytes and exit code, and the group's own switch -> pristine's bytes and exit code.
# usage: grid.sh <pristine bin> <final bin> <out>
P=$1; F=$2; OUT=$3; : > $OUT; H=$(dirname $(readlink -f $0))
D=$(dirname $(readlink -f $0))/../cases
sw() { case $1 in FC) echo R11U417_FOREACHCLASS_OFF;; FT) echo R11U417_FOREACHTD_OFF;; HP) echo R11U417_HSPARENBND_OFF;; esac; }
m() { echo "$1" | sed 's/.*rc=\([0-9]*\).*md5=\([0-9a-f]*\).*/\1:\2/'; }
cd $D; for c in */*; do g=${c%/*}
 p=$(bash $H/case.sh $c $P); f=$(bash $H/case.sh $c $F)
 o=$(bash $H/case.sh $c $F R11U417_OFF=1)
 w=$(bash $H/case.sh $c $F $(sw $g)=1)
 echo "$c | P ${p#* } | F ${f#* } | OFF=pris:$([ "$(m "$o")" = "$(m "$p")" ] && echo y || echo N) own($(sw $g))=pris:$([ "$(m "$w")" = "$(m "$p")" ] && echo y || echo N)" >> $OUT
done
