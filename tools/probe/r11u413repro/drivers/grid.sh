#!/bin/bash
# r11u413 grid: per case dir, pristine and final (case.sh lines with exit code),
# R11U413_OFF -> pristine's bytes, and the case group's own switch -> pristine's bytes.
# usage: grid.sh <pristine bin> <final bin> <out>
P=$1; F=$2; OUT=$3; : > $OUT
D=$(dirname $(readlink -f $0))/../cases
sw() { case $1 in CM) case $2 in cm08|cm10|cm11) echo R11U413_IFCALLMEMBER_OFF;; *) echo R11U413_CLSCALLMEMBER_OFF;; esac;;
  MI) echo R11U413_IFCALLMEMBER_OFF;; AI) echo R11U413_IFARRELEM_OFF;; SC) echo R11U413_COPYLHS_OFF;;
  EQ) echo R11U413_EMPTYCONCAT_OFF;; SU) echo R11U413_SUPERMEMBER_OFF;; RZ) echo R11U413_UNQRAND_OFF;;
  NU) echo R11U413_UNITBITCLONE_OFF;; esac; }
m() { echo "$1" | sed 's/.*md5=\([0-9a-f]*\).*/\1/'; }
cd $D; for c in */*; do g=${c%/*}; n=${c#*/}
 p=$(bash $(dirname $0)/case.sh $c $P); f=$(bash $(dirname $0)/case.sh $c $F)
 o=$(bash $(dirname $0)/case.sh $c $F R11U413_OFF=1)
 env=""; for s in $(sw $g $n); do env="$env $s=1"; done
 w=$(bash $(dirname $0)/case.sh $c $F $env)
 echo "$c | P ${p#* } | F ${f#* } | OFF=pris:$([ "$(m "$o")" = "$(m "$p")" ] && echo y || echo N) own($(sw $g $n | tr ' ' '+'))=pris:$([ "$(m "$w")" = "$(m "$p")" ] && echo y || echo N)" >> $OUT
done
