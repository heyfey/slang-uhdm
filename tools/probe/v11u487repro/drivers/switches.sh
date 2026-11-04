#!/bin/bash
# switches.sh <verbin> <lawbin> <pristinebin> <out> <casedir>...: per case dir, exit code and output md5
# under pristine, the law, the verified binary, the verified with R11V487_OFF=1, with R11U487_OFF=1,
# and with each refinement switch alone (outputs deleted before each run).
V=$1; L=$2; P=$3; O=$4; shift 4; : > $O
for v in V L P; do [ -x "${!v}" ] || { echo "missing $v"; exit 1; }; done
for c in "$@"; do
  c=$(realpath $c); W=/tmp/v11u487_sw$c; mkdir -p $W
  F=dut.sv; [ -f "$c/FILES" ] && F=$(cat "$c/FILES")
  run(){ rm -f $W/o.uhdm; (cd $c && env $2 "$1" $F --single-unit --nobuiltin -o $W/o.uhdm >/dev/null 2>&1 </dev/null); echo "$?:$(md5sum < $W/o.uhdm 2>/dev/null | cut -c1-8)"; }
  p=$(run $P X=1); l=$(run $L X=1); v=$(run $V X=1)
  voff=$(run $V R11V487_OFF=1); uoff=$(run $V R11U487_OFF=1)
  line="${c#*/cases/} pristine=$p law=$l ver=$( [ "$v" = "$l" ] && echo law || echo MOVED:$v) R11V487_OFF=$( [ "$voff" = "$l" ] && echo law || echo DIFF:$voff) R11U487_OFF=$( [ "$uoff" = "$p" ] && echo pristine || echo DIFF:$uoff)"
  for s in R11V487_TPSLOT_OFF R11V487_OVREFNAME_OFF; do r=$(run $V $s=1); [ "$r" = "$v" ] && x=ver || { [ "$r" = "$l" ] && x=LAW || x=OTHER:$r; }; line="$line ${s#R11V487_}=$x"; done
  echo "$line" >> $O
done
