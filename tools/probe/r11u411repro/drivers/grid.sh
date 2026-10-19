#!/bin/bash
# r11u411 grid: per case dir, pristine and final (case.sh lines with exit code),
# R11U411_OFF -> pristine's bytes, and the case group's own switch -> pristine's bytes.
# usage: grid.sh <pristine bin> <final bin> <out>
P=$1; F=$2; OUT=$3; : > $OUT
D=$(dirname $(readlink -f $0))/../cases
sw() { case $1 in EC) case $2 in ec06|ec08|ec09|ec10) echo R11U411_PKGALIASCAST_OFF;; *) echo R11U411_PKGENUMCAST_OFF;; esac;;
  GC) echo R11U411_GENVARCAST_OFF;; EF) echo R11U411_ENUMSUBSTDEC_OFF;; TC) echo R11U411_TYPEDCTOR_OFF;;
  MC) echo R11U411_CALLMEMBER_OFF;; GD) case $2 in gd03|gd04) echo "R11U411_GATEDIVSHIFT_OFF R11U411_GATEPARENSPAN_OFF";; *) echo R11U411_GATEDIVSHIFT_OFF;; esac;; esac; }
m() { echo "$1" | sed 's/.*md5=\([0-9a-f]*\).*/\1/'; }
cd $D; for c in */*; do g=${c%/*}; n=${c#*/}
 p=$(bash $(dirname $0)/case.sh $c $P); f=$(bash $(dirname $0)/case.sh $c $F)
 o=$(bash $(dirname $0)/case.sh $c $F R11U411_OFF=1)
 env=""; for s in $(sw $g $n); do env="$env $s=1"; done
 w=$(bash $(dirname $0)/case.sh $c $F $env)
 echo "$c | P ${p#* } | F ${f#* } | OFF=pris:$([ "$(m "$o")" = "$(m "$p")" ] && echo y || echo N) own($(sw $g $n | tr ' ' '+'))=pris:$([ "$(m "$w")" = "$(m "$p")" ] && echo y || echo N)" >> $OUT
done
