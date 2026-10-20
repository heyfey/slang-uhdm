#!/bin/bash
# v11u413 vgrid.sh <pristine> <final> <out> [casesdir]: per case P, F, R11U413_OFF vs P, own switch vs P
P=$1; F=$2; OUT=$3; D=${4:-/tmp/wt_v11u413/tools/probe/v11u413repro/cases}; : > $OUT
DRV=/tmp/v11u413_drv
sw() { case $1 in VC) echo R11U413_CLSCALLMEMBER_OFF R11U413_IFCALLMEMBER_OFF;; VI) echo R11U413_IFCALLMEMBER_OFF;; VA) echo R11U413_IFARRELEM_OFF;;
  VS) echo R11U413_COPYLHS_OFF;; VE) echo R11U413_EMPTYCONCAT_OFF;; VU) echo R11U413_SUPERMEMBER_OFF;; VR) echo R11U413_UNQRAND_OFF;; VN) echo R11U413_UNITBITCLONE_OFF;; esac; }
m() { echo "$1" | sed 's/.*md5=\([0-9a-f]*\).*/\1/'; }
cd $D; for c in */*; do g=${c%/*}
 p=$(bash $DRV/case.sh $c $P); f=$(bash $DRV/case.sh $c $F)
 o=$(bash $DRV/case.sh $c $F R11U413_OFF=1)
 env=""; for s in $(sw $g); do env="$env $s=1"; done
 w=$(bash $DRV/case.sh $c $F $env)
 echo "$c | P ${p#* } | F ${f#* } | OFF=pris:$([ "$(m "$o")" = "$(m "$p")" ] && echo y || echo N) own=pris:$([ "$(m "$w")" = "$(m "$p")" ] && echo y || echo N)" >> $OUT
done
