#!/bin/bash
# switchmatrix.sh <law-binary> <casedir>...: for every case-mode, the law binary with each R11U181_*_OFF switch set
# alone; prints the switches whose output differs from the law output (a switch acts only where its law fires),
# and whether R11U181_OFF gives the pristine bytes.
L=$1; shift; P=/tmp/r11u181_bin/pris.bin; T=/tmp/r11u181_sm; mkdir -p $T
SW="ROOTFN ROOTELEM ROOTNET PARENIDX INCDECBS INVSTMT DECUS DWSYN DWMACRO INCDECMIX LVCLASS LVCHAIN LVCALL NEWLHS LVIDXREAD"
one() {
  c=$1; e=$2; k=$(echo $c$e | tr '/' '_'); rm -f $T/$k.*
  (cd $c && $L $e dut.sv --single-unit --nobuiltin -o $T/$k.law >/dev/null 2>&1)
  (cd $c && $P $e dut.sv --single-unit --nobuiltin -o $T/$k.pri >/dev/null 2>&1)
  (cd $c && R11U181_OFF=1 $L $e dut.sv --single-unit --nobuiltin -o $T/$k.off >/dev/null 2>&1)
  out=""
  for s in $SW; do
    rm -f $T/$k.s
    (cd $c && env R11U181_${s}_OFF=1 $L $e dut.sv --single-unit --nobuiltin -o $T/$k.s >/dev/null 2>&1)
    cmp -s $T/$k.s $T/$k.law || out="$out $s"
  done
  lp=$(cmp -s $T/$k.law $T/$k.pri && echo law=pris || echo law!=pris)
  op=$(cmp -s $T/$k.off $T/$k.pri && echo OFF=pris || echo OFF!=pris)
  echo "$c${e:+ elab} $lp $op moved-by:${out:- none}"
  rm -f $T/$k.*
}
export -f one; export L P T SW
for c in "$@"; do echo "$c"; echo "$c --elabuhdm"; done | xargs -P 3 -I{} bash -c 'one {}' | sort
