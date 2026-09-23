#!/bin/bash
# switch116.sh <out-root> <law-binary> <arm-dir>... — per arm (a grid dir holding
# dut.sv whose <out-root>/<rel> already has pris.uhdm and law.uhdm), re-run the
# law binary (tag $LAWTAG, default law4) under each switch and report which arms each switch reverts to
# pristine bytes (REV) or leaves at law bytes (LAW) or neither (OTHER).
OUT=${1:?out}; BIN=${2:?bin}; shift 2
for sw in R11U116_OFF R11U116_F1_OFF R11U116_F2_OFF R11U116_F3R1_OFF R11U116_F3R3_OFF; do
  rev=0; law=0; oth=0; revl=""
  for a in "$@"; do
    src=$a; rel=${a#*/tools/probe/}; w=$OUT/$rel
    [ -f "$w/pris.uhdm" ] || { echo "NOPRIS $w"; continue; }
    t=$(mktemp /tmp/r11u116_sw.XXXX.uhdm)
    (cd "$src" && env $sw=1 timeout 300 "$BIN" dut.sv --single-unit --nobuiltin -o "$t" </dev/null >/dev/null 2>&1)
    if cmp -s "$t" "$w/pris.uhdm"; then rev=$((rev+1)); revl="$revl ${rel}"; elif cmp -s "$t" "$w/${LAWTAG:-law4}.uhdm"; then law=$((law+1)); else oth=$((oth+1)); echo "  OTHER $sw $rel"; fi
    rm -f "$t"
  done
  echo "$sw REV=$rev LAW=$law OTHER=$oth"
  echo "   reverted:$revl" | cut -c1-2000
done
