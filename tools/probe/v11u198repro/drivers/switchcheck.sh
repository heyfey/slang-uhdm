#!/bin/bash
# v11u198: each switch alone.  For every grid case (this directory's cases and r11u198repro's, both forms) the fix binary
# runs with R11U198_TRACE to name the laws that fire; then, per law, every case where that law is the ONLY one firing
# runs with that law's switch alone and must write the pristine bytes.  Fence fail-closed (env.sh).
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
FIX=$VB/fix1.bin; PRIS=$VB/pris.bin; T=/tmp/v11u198_swc; rm -rf $T; mkdir -p $T
declare -A SW=([genCaUnclonedFoldOwner198]=R11U198_GSOWNER_OFF [callArgVarSelStamp198]=R11U198_VSARG_OFF [genHopFoldSelName198]=R11U198_HOPSEL_OFF [ovrParamBoundOpSelName198]=R11U198_OVRBOUND_OFF [methodArgOpRefChainName198]=R11U198_MARGOP_OFF [lvIdxCallArgIsRead198]=R11U198_LVCALLARG_OFF [genCaCastRhsRefUnnamed198]=R11U198_CASTRHS_OFF [vsStampReducedCtxOnly198v]=R11V198_VSSYS_OFF)
run() { D=$1; out=$2; shift 2; SRC=dut.sv; [ -f "$D/args" ] && SRC=$(cat "$D/args"); rm -f $out; (cd $D && env "$@" $SRC --single-unit --nobuiltin $OUE -o $out >/dev/null 2>&1); md5sum < $out 2>/dev/null | cut -c1-12; }
for form in parse elab; do OUE=; [ $form = elab ] && OUE=--elabuhdm
  for c in $HERE/../cases/*/* $HERE/../../r11u198repro/cases/*/*; do D=$(cd $c && pwd); for f in $FENCED; do grep -qw "$f" <<< "$D" && exit 3; done
    k=$(echo "$D$form" | md5sum | cut -c1-10); mkdir -p $T/$k/tr
    p=$(run $D $T/$k/p.uhdm $PRIS); run $D $T/$k/f.uhdm R11U198_TRACE=$T/$k/tr $FIX >/dev/null
    laws=$(cat $T/$k/tr/*.T198 2>/dev/null | grep -v '^OUT' | sort -u | tr '\n' ' ')
    n=$(echo $laws | wc -w)
    if [ $n = 0 ]; then echo "$form NOFIRE $(echo $D | sed 's#.*/probe/##')"; continue; fi
    if [ $n = 1 ]; then l=$(echo $laws); s=$(run $D $T/$k/s.uhdm ${SW[$l]}=1 $FIX); [ "$s" = "$p" ] && v=PRISTINE || v=DIFFERS; echo "$form ALONE $l $v $(echo $D | sed 's#.*/probe/##')"
    else echo "$form MIXED $(echo $laws | tr ' ' '+') $(echo $D | sed 's#.*/probe/##')"; fi
  done; done
