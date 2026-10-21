#!/bin/bash
# r11u423 grid: per case dir, pristine and law (case.sh lines with exit code),
# R11U423_OFF -> pristine's bytes and exit code, and every single switch: which ones restore pristine.
# usage: grid.sh <pristine bin> <law bin> <out>
P=$1; F=$2; OUT=$3; : > $OUT; H=$(dirname $(readlink -f $0))
SW="R11U423_CIOPS_OFF R11U423_CILATE_OFF R11U423_CICLSOWN_OFF R11U423_CLSOPLATE_OFF R11U423_UNSZFOLD_OFF R11U423_DECUNSZ_OFF R11U423_OCTUNSZ_OFF"
m() { echo "$1" | sed 's/.*rc=\([0-9]*\).*md5=\([0-9a-f]*\).*/\1:\2/'; }
cd $H/../cases; for c in */*; do
 p=$(bash $H/case.sh $c $P); f=$(bash $H/case.sh $c $F)
 o=$(bash $H/case.sh $c $F R11U423_OFF=1)
 own=""; for s in $SW; do w=$(bash $H/case.sh $c $F $s=1); [ "$(m "$w")" = "$(m "$p")" ] && [ "$(m "$f")" != "$(m "$p")" ] && own="$own ${s#R11U423_}"; done
 echo "$c | P ${p#* } | F ${f#* } | OFF=pris:$([ "$(m "$o")" = "$(m "$p")" ] && echo y || echo N) moved:$([ "$(m "$f")" = "$(m "$p")" ] && echo n || echo y) restoredBy:${own:- -}" >> $OUT
done
