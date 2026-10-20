#!/bin/bash
# v11u417 vgrid.sh <casesdir> <out>: verified result; R11V417_OFF -> law bytes; R11U417_OFF -> pristine bytes
P=/tmp/v11u417_bin/pristine; L=/tmp/v11u417_bin/law; V=/tmp/v11u417_bin/verified; D=$1; OUT=$2; : > $OUT; H=/tmp/v11u417_drv
m() { echo "$1" | sed 's/.*rc=\([0-9]*\).*md5=\([0-9a-f]*\).*/\1:\2/'; }
cd $D; for c in ${CASES:-*/*}; do
 p=$(bash $H/case.sh $c $P); l=$(bash $H/case.sh $c $L); v=$(bash $H/case.sh $c $V)
 vo=$(bash $H/case.sh $c $V R11V417_OFF=1); uo=$(bash $H/case.sh $c $V R11U417_OFF=1)
 echo "$c | P ${p#* } | L ${l#* } | V ${v#* } | VOFF=law:$([ "$(m "$vo")" = "$(m "$l")" ] && echo y || echo N) UOFF=pris:$([ "$(m "$uo")" = "$(m "$p")" ] && echo y || echo N)" >> $OUT
done
