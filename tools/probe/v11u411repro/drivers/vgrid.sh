#!/bin/bash
# vgrid.sh <casesroot> <out>: law vs verified, R11V411_OFF -> law bytes, R11U411_OFF -> pristine bytes, own refinement switch -> law bytes
R=$1; OUT=$2; : > $OUT; m() { echo "$1" | sed 's/.*md5=\([0-9a-f]*\).*/\1/'; }
cd $R; for c in */*; do
 p=$(/tmp/v11u411_drv/case.sh $c /tmp/v11u411_bin/pristine); l=$(/tmp/v11u411_drv/case.sh $c /tmp/v11u411_bin/law); v=$(/tmp/v11u411_drv/case.sh $c /tmp/v11u411_bin/verified)
 vo=$(/tmp/v11u411_drv/case.sh $c /tmp/v11u411_bin/verified R11V411_OFF=1); uo=$(/tmp/v11u411_drv/case.sh $c /tmp/v11u411_bin/verified R11U411_OFF=1)
 own=$(/tmp/v11u411_drv/case.sh $c /tmp/v11u411_bin/verified R11V411_CTORPROG_OFF=1 R11V411_DECZERO_OFF=1 R11V411_GATEMOD_OFF=1 R11V411_PARENWS_OFF=1)
 s(){ echo "$1" | sed 's/out=[^ ]* //;s/^[a-z0-9]* //'; }
 echo "$c | L $(s "$l") | V $(s "$v") | VOFF=law:$([ "$(m "$vo")" = "$(m "$l")" ] && echo y || echo N) UOFF=pris:$([ "$(m "$uo")" = "$(m "$p")" ] && echo y || echo N) allfix=law:$([ "$(m "$own")" = "$(m "$l")" ] && echo y || echo N) V=L:$([ "$(m "$v")" = "$(m "$l")" ] && echo y || echo N)" >> $OUT
done
