#!/bin/bash
# swtable.sh <bin> <listfile>: for each pass-484 switch, the case dirs whose bytes move when that
# switch alone is set (against the binary with no switch).  Absolute case directories only.
B=$1; L=$2
for c in $(cat "$L"); do
  W=/tmp/r11u484_sw$c; mkdir -p "$W"; rm -f "$W"/*.uhdm
  (cd "$c" && "$B" dut.sv --single-unit --nobuiltin -o "$W/base.uhdm" >/dev/null 2>&1 </dev/null)
  for sw in ALIASLOCAL ALIASMEMBINST ALIASTGTTOP ALIASCOPYNAME MODALIASTD; do
    (cd "$c" && env R11U484_${sw}_OFF=1 "$B" dut.sv --single-unit --nobuiltin -o "$W/$sw.uhdm" >/dev/null 2>&1 </dev/null)
    cmp -s "$W/base.uhdm" "$W/$sw.uhdm" || echo "${c#*/tools/probe/} $sw"
  done
done
