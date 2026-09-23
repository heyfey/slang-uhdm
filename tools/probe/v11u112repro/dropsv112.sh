#!/bin/bash
# drops: per switch config, compile every arm (u2r form) with vfx2 + env; compare to vfx2.uhdm and pris.uhdm
B=${BIN:?fix binary}; VR=${VROOT:-/tmp/v11u112}; O=${VR}_drops; mkdir -p $O
LIST=$(mktemp $O/list.XXXX)
for R in brk brk2 brk3 brk4 brk6; do (cd ${VR}_$R && find . -name dut.sv | sed "s#^\./#$R/#"); done > $LIST
(cd ${IGRID:?r11u112repro/grid} && find . -name dut.sv | sed 's#^\./#igrid/#') >> $LIST
for sw in R11U112_OFF R11U112_PROPDIS_OFF R11U112_TDCAST_OFF R11U112_TDRET_OFF R11U112_TPNET_OFF R11U112_GENIPS_OFF R11U112_SELIDXTS_OFF R11U112_GENLPOP_OFF V11U112_ENUMFENCE_OFF V11U112_PROPFENCE_OFF; do
  nv=0; np=0; n=0; chg=""
  while read -r rel <&3; do
    top=${rel%%/*}; rest=${rel#*/}; arm=$(dirname $rest)
    if [ $top = igrid ]; then src=${IGRID:?r11u112repro/grid}/$arm; out=${VR}_igrid/$arm/u2r; else src=${VR}_$top/$arm; out=${VR}_${top}out/$arm/u2r; fi
    [ -f $out/vfx2.uhdm ] || continue
    rm -f $O/x.uhdm; (cd $src && env $sw=1 timeout 300 $B dut.sv --single-unit --nobuiltin -o $O/x.uhdm </dev/null >/dev/null 2>&1)
    n=$((n+1))
    cmp -s $O/x.uhdm $out/vfx2.uhdm || { nv=$((nv+1)); chg="$chg $top/$arm"; }
    cmp -s $O/x.uhdm $out/pris.uhdm && np=$((np+1))
  done 3< $LIST
  echo "$sw arms=$n differ_from_vfx2=$nv equal_pris=$np :$chg"
done
