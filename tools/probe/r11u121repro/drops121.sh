#!/usr/bin/env bash
# r11u121 drops: every grid arm, both forms (probe: dut.sv --single-unit --nobuiltin;
# downstream: -DSYNTHESIS ...), LAW binary with one switch set vs LAW (no switch) and vs PRISTINE.
# usage: drops121.sh <law bin> <pristine bin> <scratch>
set -u
L=$1; P=$2; S=$3; D=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$S"
run() { # bin env form arm -> md5
  local b=$1 e=$2 f=$3 a=$4
  local o="$S/$(echo "$a$e$f$b" | md5sum | cut -c1-12).uhdm"
  rm -f "$o"
  if [ "$f" = ds ]; then (cd "$a" && env $e "$b" -DSYNTHESIS dut.sv --single-unit --nobuiltin -o "$o" >/dev/null 2>&1 </dev/null)
  else (cd "$a" && env $e "$b" dut.sv --single-unit --nobuiltin -o "$o" >/dev/null 2>&1 </dev/null); fi
  echo "$? $(md5sum < "$o" 2>/dev/null | cut -c1-12)"; rm -f "$o"
}
arms=$(find "$D/grid" -name dut.sv -printf '%h\n' | sort)
n=0
for sw in R11U121_OFF R11U121_TPGS_OFF R11U121_QMSEL_OFF R11U121_PVSPAN_OFF R11U121_PVSP_OFF; do
  mv=0; pr=0; tot=0; names=""
  for a in $arms; do for f in pr ds; do
    tot=$((tot+1))
    l=$(run "$L" "X=1" $f "$a"); x=$(run "$L" "$sw=1" $f "$a"); p=$(run "$P" "X=1" $f "$a")
    [ "$x" != "$l" ] && { mv=$((mv+1)); names="$names $(basename $a)/$f"; }
    [ "$x" = "$p" ] && pr=$((pr+1))
  done; done
  echo "$sw: moved-vs-LAW=$mv  =pristine=$pr/$tot  :$names"
done
