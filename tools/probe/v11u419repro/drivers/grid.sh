#!/bin/bash
# v11u419 grid: per case dir, pristine and law (case.sh lines with exit code),
# R11U419_OFF -> pristine's bytes and exit code, the law's own switch (from the case's first line) -> pristine's.
# usage: grid.sh <pristine bin> <law bin> <out> [case globs...]
P=$1; F=$2; OUT=$3; shift 3; : > $OUT; H=$(dirname $(readlink -f $0))
cd $H/../cases
sw() { case $(head -1 $1/dut.sv | sed 's/.*§ //') in
  ifPortViewArithIntForm419) echo R11U419_PVINTFORM_OFF=1;; ifPortViewPaLhsOwn419) echo R11U419_PVLHSOWN_OFF=1;;
  ifPortViewTdAliasDefName419) echo R11U419_PVTDALIAS_OFF=1;; implicitPortParamListedFirst419) echo R11U419_IMPLFIRST_OFF=1;;
  implicitPortPaLastIface419) echo R11U419_IMPLPALAST_OFF=1;; *) echo NONE=1;; esac; }
m() { echo "$1" | sed 's/.*rc=\([0-9]*\).*md5=\([0-9a-f]*\).*/\1:\2/'; }
for c in ${@:-*/*}; do
 p=$(bash $H/case.sh $c $P); f=$(bash $H/case.sh $c $F)
 o=$(bash $H/case.sh $c $F R11U419_OFF=1); w=$(bash $H/case.sh $c $F $(sw $c))
 echo "$c | P ${p#* } | F ${f#* } | OFF=pris:$([ "$(m "$o")" = "$(m "$p")" ] && echo y || echo N) own=pris:$([ "$(m "$w")" = "$(m "$p")" ] && echo y || echo N)" >> $OUT
done
