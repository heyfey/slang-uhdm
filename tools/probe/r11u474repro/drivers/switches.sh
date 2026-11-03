#!/bin/bash
# switches.sh <pristine> <law> <casedir>...: md5 of ours per case for pristine, law, law+R11U474_OFF and
# law with each single switch off; prints which switch restores pristine's bytes
P=$1; L=$2; shift 2
[ -x "$P" ] && [ -x "$L" ] || { echo "missing binary"; exit 1; }
SW="R11U474_THISREGDEF_OFF R11U474_CLSRANGE_OFF R11U474_PARAMSUBST_OFF R11U474_CLONEPARNAME_OFF"
m(){ local d=$1; shift; rm -f /tmp/r11u474_sw.uhdm; (cd $d && env "$@" dut.sv --single-unit --nobuiltin -o /tmp/r11u474_sw.uhdm >/dev/null 2>&1 </dev/null); echo "$?:$(md5sum < /tmp/r11u474_sw.uhdm 2>/dev/null | cut -c1-8)"; }
for c in "$@"; do [ -d "$c" ] || continue
  p=$(m $c $P); l=$(m $c $L); o=$(m $c R11U474_OFF=1 $L)
  line="${c#*/cases/} pris=$p law=$l OFF=$([ "$o" = "$p" ] && echo pristine || echo DIFF:$o)"
  if [ "$p" != "$l" ]; then r=""; for s in $SW; do x=$(m $c $s=1 $L); [ "$x" = "$p" ] && r="$r ${s#R11U474_}"; done; line="$line restored-by:${r:- (none alone)}"; fi
  echo "$line"
done
