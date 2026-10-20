#!/bin/bash
# r11u415 grid: per case dir, pristine and final (case.sh lines with exit code),
# R11U415_OFF -> pristine's bytes and exit code, and the group's own switch -> pristine's bytes and exit code.
# usage: grid.sh <pristine bin> <final bin> <out>
P=$1; F=$2; OUT=$3; : > $OUT
D=$(dirname $(readlink -f $0))/../cases
sw() { case $1 in TC) echo R11U415_THISCALLMEMBER_OFF;; BC) echo R11U415_BADCASTSIZE_OFF;;
  LT) echo R11U415_PKGLET_OFF;; LB) echo R11U415_LABELCALL_OFF;;
  DN) echo "R11U415_DISABLEHIER_OFF R11U415_DISABLEHIERTASK_OFF";; FJ) echo R11U415_EXTERNCALL_OFF;; esac; }
m() { echo "$1" | sed 's/.*rc=\([0-9]*\).*md5=\([0-9a-f]*\).*/\1:\2/'; }
cd $D; for c in */*; do g=${c%/*}
 p=$(bash $(dirname $0)/case.sh $c $P); f=$(bash $(dirname $0)/case.sh $c $F)
 o=$(bash $(dirname $0)/case.sh $c $F R11U415_OFF=1)
 env=""; for s in $(sw $g); do env="$env $s=1"; done
 w=$(bash $(dirname $0)/case.sh $c $F $env)
 echo "$c | P ${p#* } | F ${f#* } | OFF=pris:$([ "$(m "$o")" = "$(m "$p")" ] && echo y || echo N) own($(sw $g | tr ' ' '+'))=pris:$([ "$(m "$w")" = "$(m "$p")" ] && echo y || echo N)" >> $OUT
done
