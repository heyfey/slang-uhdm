#!/bin/bash
# switchcheck.sh <law-bin> <pristine-bin> <casedir>...: per case, md5 of pristine, of the law binary
# with R11U460_OFF=1, and with each law switch alone; prints OFF=same|DIFF.  Explicit case dirs only.
L=$1; P=$2; shift 2
[ -x "$L" ] && [ -x "$P" ] || { echo "no binary"; exit 1; }
W=/tmp/r11u460_sw_cases; mkdir -p $W
SW="PKGTDSPEC NESTCLONEINST SPECALIASROOT OOBCOPYCALL IFCOWNTRANS IFCTFORDER PATBASEDW IMPNETAFTER"
for c in "$@"; do
  [ -d "$c" ] || continue
  run(){ rm -f $W/o.uhdm; (cd "$c" && env "$@" dut.sv -o $W/o.uhdm >/dev/null 2>&1 </dev/null); echo "$?:$(md5sum < $W/o.uhdm | cut -c1-8)"; }
  p=$(run $P); off=$(run R11U460_OFF=1 $L); l=$(run $L); line="${c#*/cases/} pris=$p off=$off $([ $p = $off ] && echo OFF=same || echo OFF=DIFF) law=$l"
  for s in $SW; do x=$(run R11U460_${s}_OFF=1 $L); [ "$x" != "$l" ] && line="$line ${s}_off=$x"; done
  echo "$line"
done
