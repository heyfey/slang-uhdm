#!/bin/bash
# r11u186: every switch alone on the final binary (FINALBIN, default final2.bin; its grid REFTAG, default gZ2), over the case dirs given: prints `<switch> <n moved> <cases>`, the
# cases whose database bytes differ from the final binary's with every switch on (the gZ grid's ours.uhdm).
# usage: switches.sh <case dir>...   (refuses fenced paths)
. /tmp/wt_r11u186/tools/probe/r11u186repro/drivers/env.sh || exit 3
SW="R11U183_RANGEFILE_OFF R11U183_ASSOCBRACKET_OFF R11U183_PKGPARAMTS_OFF R11U183_ELABCAFOLD_OFF R11U183_TSSPAN_OFF
R11U183_PROPELEM_OFF R11U183_FEIDX_OFF R11U183_TYPEPARAM_OFF R11U183_IMPNETTS_OFF R11U183_IFARR_OFF R11U183_UARANGE_OFF
R11U183_PATHSPAN_OFF R11U183_BITTSNAME_OFF R11U183_UVMCOPY_OFF R11U183_IMPCOPY_OFF R11U183_ALIASNAME_OFF R11U183_OFF
R11U186_ENUMUS_OFF R11U186_SYNUS_OFF R11U186_BOUNDUS_OFF R11U186_PROPELEMQUAL_OFF R11U186_IFACE2PKG_OFF
R11U186_LAWSSORT_OFF R11U186_ROOTELEM_OFF R11U186_PATHBUF_OFF R11U186_ASSOCPKG_OFF R11U186_TPGATE_OFF R11U186_TPDEFER_OFF R11U186_OFF"
for d in "$@"; do find $(cd $d && pwd) -name dut.sv -printf '%h\n'; done | sort -u > /tmp/r11u186_sw_list
one() { s=$1; c=$2; r=$(echo "$c" | sed 's#.*/tools/probe/##'); ref=/tmp/r11u186_grid/${REFTAG:-gZ2}/${FINALBIN:-final2.bin}/$r/ours.uhdm
  [ -s $ref ] || return; o=/tmp/r11u186_sw/$s/$(echo $r | tr / _); mkdir -p $(dirname $o); rm -f $o
  ( cd $c && env $s=1 /tmp/r11u186_bin/${FINALBIN:-final2.bin} dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1 </dev/null )
  cmp -s $o $ref || echo "$s $r"; }
export -f one; export FINALBIN REFTAG
for s in $SW; do while read -r c; do echo "$s $c"; done < /tmp/r11u186_sw_list; done | xargs -P3 -L1 bash -c 'one $0 $1' > /tmp/r11u186_sw_moves.txt
for s in $SW; do n=$(grep -c "^$s " /tmp/r11u186_sw_moves.txt); echo "$s moved=$n $(grep "^$s " /tmp/r11u186_sw_moves.txt | awk '{print $2}' | sed 's#/dut.sv##' | tr '\n' ' ')"; done
