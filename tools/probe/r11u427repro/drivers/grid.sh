#!/bin/bash
# r11u427 grid: per case dir, pristine and law (case.sh lines with exit code),
# R11U427_OFF -> pristine's bytes and exit code, and every single switch: which ones restore pristine.
# usage: grid.sh <pristine bin> <law bin> <out>
P=$1; F=$2; OUT=$3; : > $OUT; H=$(dirname $(readlink -f $0))
SW="R11U427_XZOVLIT_OFF R11U427_OVTSDECLW_OFF R11U427_SGNBINBRANCH_OFF R11U427_SGNBINTSU_OFF R11U427_ELABLOWBASE_OFF R11U427_ELABUNSZXZ_OFF R11U427_XPKGFOLD_OFF R11U427_ONEBITX_OFF R11U427_TYPEDLITADJ_OFF"
m() { echo "$1" | sed 's/.*rc=\([0-9]*\).*md5=\([0-9a-f]*\).*/\1:\2/'; }
cd $H/../cases; for c in */*; do
 p=$(bash $H/case.sh $c $P); f=$(bash $H/case.sh $c $F)
 o=$(bash $H/case.sh $c $F R11U427_OFF=1)
 own=""; for s in $SW; do w=$(bash $H/case.sh $c $F $s=1); [ "$(m "$w")" = "$(m "$p")" ] && [ "$(m "$f")" != "$(m "$p")" ] && own="$own ${s#R11U427_}"; done
 echo "$c | P ${p#* } | F ${f#* } | OFF=pris:$([ "$(m "$o")" = "$(m "$p")" ] && echo y || echo N) moved:$([ "$(m "$f")" = "$(m "$p")" ] && echo n || echo y) restoredBy:${own:- -}" >> $OUT
done
