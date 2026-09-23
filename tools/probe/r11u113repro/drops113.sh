#!/bin/bash
# drops113.sh <grid-out-root> <law-binary> <law-tag> <pris-tag>: per-switch drops.  For every arm
# (u2r form) holding <law-tag>.uhdm and <pris-tag>.uhdm, the law binary is re-run with ONE switch
# set (and with R11U113_OFF=1) into ${DROPWD:-/tmp/r11u113_drops}; each database is compared byte
# for byte with the LAW and PRISTINE ones.  Prints, per switch, the arms that moved away from LAW
# and the arms that do NOT equal PRISTINE under R11U113_OFF.
R=${1:?root}; B=${2:?bin}; LT=${3:?lawtag}; PT=${4:?pristag}; O=${DROPWD:-/tmp/r11u113_drops}; mkdir -p "$O"
GRID=$(cd "$(dirname "$0")" && pwd)/grid
SW="R11U113_OFF R11U113_RBND_OFF R11U113_TPCAST_OFF R11U113_ENUM_OFF R11U113_REPRNG_OFF R11U113_VSIDX_OFF R11U113_GSBS_OFF"
for sw in $SW; do
  moved=(); notpris=()
  for d in $(find "$R" -path '*/u2r' -type d | sort); do
    [ -f "$d/$LT.uhdm" ] && [ -f "$d/$PT.uhdm" ] || continue
    arm=${d#$R/}; arm=${arm%/u2r}; src=$(find "$GRID" -type d -path "*/$arm" | head -1); [ -n "$src" ] || continue
    k=$(echo "$arm" | tr '/' '_'); out="$O/$k.$sw.uhdm"; rm -f "$out"
    (cd "$src" && env $sw=1 timeout 300 "$B" dut.sv --single-unit --nobuiltin -o "$out" </dev/null >/dev/null 2>&1)
    cmp -s "$out" "$d/$LT.uhdm" || moved+=("$arm")
    [ "$sw" = R11U113_OFF ] && { cmp -s "$out" "$d/$PT.uhdm" || notpris+=("$arm"); }
  done
  echo "$sw moved=${#moved[@]}: ${moved[*]}"
  [ "$sw" = R11U113_OFF ] && echo "R11U113_OFF not-pristine=${#notpris[@]}: ${notpris[*]}"
done
