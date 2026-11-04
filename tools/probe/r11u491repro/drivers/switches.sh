#!/bin/bash
# switches.sh <lawbin> <dir>...: md5 of pristine, law, law+R11U491_OFF, law+each law switch
L=$1; shift; [ -x "$L" ] && [ -x /tmp/r11u491_bin/pristine ] || exit 1
SW="BITNEGTYPED BITNEGUNSZACT OVUNSZFORM OVSIZEDMORE BITNEGBARENAME DEPBESIDEDP SUBSIZE64"
run() { local o=/tmp/r11u491_sw/$$.uhdm; rm -f $o; (cd "$1" && env $2 "$3" dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1); echo "$?:$(md5sum < $o 2>/dev/null | cut -c1-8)"; rm -f $o; }
mkdir -p /tmp/r11u491_sw
for d in "$@"; do
  p=$(run "$d" X=1 /tmp/r11u491_bin/pristine); l=$(run "$d" X=1 "$L"); off=$(run "$d" R11U491_OFF=1 "$L")
  line="${d#*/tools/probe/} pris=$p law=$l OFF=$([ "$off" = "$p" ] && echo pristine || echo DIFF:$off)"
  if [ "$p" != "$l" ]; then by=""; for s in $SW; do x=$(run "$d" R11U491_${s}_OFF=1 "$L"); [ "$x" != "$l" ] && by="$by $s"; done; line="$line moved-by:$by"; fi
  echo "$line"
done
