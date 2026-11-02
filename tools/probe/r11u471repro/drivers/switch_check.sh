#!/bin/bash
# switch_check.sh <law bin> <pristine bin>: per case dir, md5 of the law binary's output with
# R11U471_OFF and with each law's own switch, against pristine's and the law's own bytes.
H=$(cd "$(dirname "$0")/.." && pwd)
L=$1; P=$2; T=/tmp/r11u471_sw_chk; mkdir -p $T
run(){ rm -f $T/o.uhdm; (cd "$1" && env $2 "$3" dut.sv --single-unit --nobuiltin -o $T/o.uhdm >/dev/null 2>&1 </dev/null); echo "$? $(md5sum < $T/o.uhdm 2>/dev/null | cut -c1-8)"; }
for c in "$H"/cases/*/*/; do
  p=$(run "$c" X=1 "$P"); l=$(run "$c" X=1 "$L"); o=$(run "$c" R11U471_OFF=1 "$L")
  line="${c#$H/cases/} pris=[$p] law=[$l] OFF=[$o]"; [ "$o" = "$p" ] && line="$line OFF_OK" || line="$line OFF_BAD"
  for sw in R11U471_ENUMSHAREDINST_OFF R11U471_EXPORTITEM_OFF R11U471_TDIMPFOLDTS_OFF R11U471_PROCASGTS_OFF R11U471_PKGINITFOLD_OFF; do
    s=$(run "$c" $sw=1 "$L"); [ "$s" != "$l" ] && line="$line ${sw#R11U471_}=moves"; [ "$s" = "$p" ] && [ "$l" != "$p" ] && line="$line ${sw#R11U471_}=restores"
  done
  echo "$line"
done
