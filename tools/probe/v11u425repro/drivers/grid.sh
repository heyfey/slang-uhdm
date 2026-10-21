#!/bin/bash
# v11u425 grid: grid.sh <pristine> <law> <out> [case globs...]; per case: pristine line, law line, R11U425_OFF restores pristine?, which single switch restores pristine
P=$1; F=$2; OUT=$3; shift 3; : > $OUT; H=$(dirname $(readlink -f $0))
SW="R11U425_ONETICKB_OFF R11U425_LINEPLUS1_OFF R11U425_ELABFORM_OFF R11U425_NDANOTS_OFF R11U425_BINNDATICK_OFF"
m() { echo "$1" | sed 's/.*rc=\([0-9]*\).*md5=\([0-9a-f]*\).*/\1:\2/'; }
cd $H/../cases; for c in ${@:-*/*}; do
 p=$(bash $H/case.sh $c $P); f=$(bash $H/case.sh $c $F)
 o=$(bash $H/case.sh $c $F R11U425_OFF=1)
 own=""; if [ "$(m "$f")" != "$(m "$p")" ]; then for s in $SW; do w=$(bash $H/case.sh $c $F $s=1); [ "$(m "$w")" = "$(m "$p")" ] && own="$own ${s#R11U425_}"; done; fi
 echo "$c | P ${p#* } | F ${f#* } | OFF=pris:$([ "$(m "$o")" = "$(m "$p")" ] && echo y || echo N) moved:$([ "$(m "$f")" = "$(m "$p")" ] && echo n || echo y) restoredBy:${own:- -}" >> $OUT
done
