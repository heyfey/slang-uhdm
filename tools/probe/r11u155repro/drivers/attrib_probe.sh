#!/bin/bash
# attrib_probe.sh <moverlist> <outdir>: for every probe case that moved (file names as the sweep
# writes them, `a__b__c.uhdm`), re-run the law binary once per r11u155 switch and name the switch
# whose run returns the case to the pristine sweep's bytes.
L=${LAW:-/tmp/r11u155_bin/law2.bin}; P=${PRIS:-/tmp/r11u155_swP}/probe; O=$2; mkdir -p $O
R=$(cd $(dirname $0)/../../../.. && pwd)
SW="R11U155_OFF R11U155_PRGINITEND_OFF R11U155_IMPLARGDIM_OFF R11U155_NAARRNET_OFF R11U155_UNITUNIONARG_OFF R11U155_UNITSTRUCTARG_OFF R11U155_PSELNAME_OFF R11U155_NDAFOLDLOC_OFF R11U155_PVLEFTOP_OFF R11U155_TDSTRETCHHDR_OFF R11U155_MODAGGARG_OFF R11U155_DIRLESSNAME_OFF R11U155_IFSIGCHILD_OFF"
while read f; do
  rel=$(echo ${f%.uhdm} | sed 's#__#/#g'); hits=""
  for sw in $SW; do
    o=$O/$(echo $f | sed "s/.uhdm$/.$sw.uhdm/"); rm -f $o
    (cd $R/tests/probe/$rel && env $sw=1 $L dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1)
    cmp -s $o $P/$f && hits="$hits $sw"
    rm -f $o
  done
  echo "$rel:$hits"
done < $1
