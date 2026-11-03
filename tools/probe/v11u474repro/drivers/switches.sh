#!/bin/bash
# switches.sh <pristine> <law> <verified> <casedir>...: per case the exit code and md5 of ours on
# pristine, law and verified, verified with R11U474_OFF (must equal pristine), verified with
# R11V474_OFF and with R11V474_REGORDER_OFF (must equal law), and for each mover the single law
# switches that alone restore pristine's bytes on the verified binary
P=$1; L=$2; V=$3; shift 3
for b in "$P" "$L" "$V"; do [ -x "$b" ] || { echo "missing binary $b"; exit 1; }; done
SW="R11U474_THISREGDEF_OFF R11U474_CLSRANGE_OFF R11U474_PARAMSUBST_OFF R11U474_CLONEPARNAME_OFF"
O=/tmp/v11u474_sw.uhdm
m(){ local d=$1; shift; rm -f $O; local F=dut.sv; [ -f "$d/FILES" ] && F=$(cat "$d/FILES"); (cd $d && env "$@" $F --single-unit --nobuiltin -o $O >/dev/null 2>&1 </dev/null); echo "$?:$(md5sum < $O 2>/dev/null | cut -c1-8)"; }
for c in "$@"; do [ -d "$c" ] || continue; c=$(realpath $c)
  p=$(m $c $P); l=$(m $c $L); v=$(m $c $V); o=$(m $c R11U474_OFF=1 $V); vo=$(m $c R11V474_OFF=1 $V); vr=$(m $c R11V474_REGORDER_OFF=1 $V)
  line="${c#*/cases/} pris=$p law=$l ver=$v U474OFF=$([ "$o" = "$p" ] && echo pristine || echo DIFF:$o) V474OFF=$([ "$vo" = "$l" ] && echo law || echo DIFF:$vo) REGORDER_OFF=$([ "$vr" = "$l" ] && echo law || echo DIFF:$vr)"
  if [ "$p" != "$v" ]; then r=""; for s in $SW; do x=$(m $c $s=1 $V); [ "$x" = "$p" ] && r="$r ${s#R11U474_}"; done; line="$line restored-by:${r:- (none alone)}"; fi
  echo "$line"
done
