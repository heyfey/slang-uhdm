#!/bin/bash
# switches.sh <pristine> <law> <outdir>: each law's switch alone, on the grid of this pass: for every
# case, the law binary with that one switch set is compared byte for byte with pristine; a grid whose
# only law is the switched one must read all-identical.
P=$1; L=$2; O=$3; mkdir -p $O
C=$(cd $(dirname $0)/../cases && pwd)
for sw in R11U169_GCACHAIN_OFF R11U169_MLLOC_OFF R11U169_MLARGLOC_OFF R11U169_PATFLATSPAN_OFF; do
  for g in gc ml pf; do
    same=0; diff=0; lst=""
    for d in $C/$g/*/; do k=$g_$(basename $d); rm -f $O/p.uhdm $O/s.uhdm
      (cd $d && $P dut.sv --single-unit --nobuiltin -o $O/p.uhdm </dev/null >/dev/null 2>&1)
      (cd $d && env $sw=1 $L dut.sv --single-unit --nobuiltin -o $O/s.uhdm </dev/null >/dev/null 2>&1)
      if cmp -s $O/p.uhdm $O/s.uhdm; then same=$((same+1)); else diff=$((diff+1)); lst="$lst $(basename $d)"; fi
    done
    echo "$sw grid=$g identical_to_pristine=$same differ=$diff:$lst"
  done
done
