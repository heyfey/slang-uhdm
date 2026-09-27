#!/bin/bash
# sw1.sh <case> : md5 of ours per switch set on fix2.bin (no golden)
c=$1; cd /tmp/v11u180_cases/$c; FILES=$( [ -f files ] && cat files || echo dut.sv )
o=/tmp/v11u180_scr/swt/$(echo $c | tr / _); mkdir -p $o
for sw in NONE R11U180_ENUMIMP_OFF R11U180_ENUMIMPHDR_OFF R11U180_TPUSE_OFF R11U180_TPFORMAL_OFF R11U180_TPCHAIN_OFF R11U180_TPQUAL_OFF R11U180_MODAGGCLONE_OFF R11U180_PKGAGGCLONE_OFF R11U180_IFACETDORDER_OFF R11U180_PORTINTREDECL_OFF R11U180_AGGSWITCH_OFF R11V180_ENUMDEF_OFF R11V180_MODAGGDEF_OFF R11V180_MODAGGFILE_OFF R11V180_OFF R11U180_OFF; do
  rm -f $o/$sw.uhdm
  env $([ $sw = NONE ] || echo $sw=1) /tmp/v11u180_bin/fix4.bin $FILES --single-unit --nobuiltin -o $o/$sw.uhdm >/dev/null 2>&1
  printf "%s %s %s\n" $c $sw $(md5sum < $o/$sw.uhdm | cut -c1-8)
done
