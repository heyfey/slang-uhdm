#!/bin/bash
# drops113v.sh — per-switch drop check.  VBIN=<law binary> DROPWD=<scratch> ROOTS="<griddir>:<grid113.sh out-root> ..."
# Each arm/form under every root must already hold vfx2.uhdm (the law binary's db) and pris.uhdm
# (grid113.sh tags); recompiles with each switch set and compares.
B=${VBIN:?binary}; OUT=${DROPWD:?scratch}; mkdir -p $OUT
for sw in R11U113_OFF R11U113_RBND_OFF R11U113_TPCAST_OFF R11U113_ENUM_OFF R11U113_REPRNG_OFF R11U113_VSIDX_OFF R11U113_GSBS_OFF; do
  ch=0; same=0; offp=0; n=0; list=""
  for root in ${ROOTS:?roots}; do
    G=${root%%:*}; O=${root#*:}
    while read -r rel <&3; do
      arm=$(dirname ${rel#./})
      for form in u2r elab; do
        w=$O/$arm/$form; [ -f $w/vfx2.uhdm ] || continue
        ex=(); [ $form = elab ] && ex=(--elabuhdm)
        (cd $G/$arm && env $sw=1 timeout 300 $B "${ex[@]}" dut.sv --single-unit --nobuiltin -o $OUT/x.uhdm </dev/null >/dev/null 2>&1)
        n=$((n+1))
        if cmp -s $OUT/x.uhdm $w/vfx2.uhdm; then same=$((same+1)); else ch=$((ch+1)); list="$list ${G##*/}:$arm/$form"; fi
        if [ $sw = R11U113_OFF ]; then cmp -s $OUT/x.uhdm $w/pris.uhdm && offp=$((offp+1)); fi
        rm -f $OUT/x.uhdm
      done
    done 3< <(cd $G && find . -name dut.sv | sort)
  done
  echo "$sw n=$n same_as_vfx2=$same changed=$ch offEqPris=$offp"
  echo "  CHANGED:$list" | tr ' ' '\n' | sed 's#/\(u2r\|elab\)$##' | sort -u | tr '\n' ' '; echo
done
