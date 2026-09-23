#!/bin/bash
# drops115.sh <grid-out-root> <law-binary> <law-tag> <pris-tag>: for every arm/form under the
# grid output root that holds <law-tag>.uhdm and <pris-tag>.uhdm, recompile with each r11u115
# switch set (one at a time, and R11U115_OFF=1) and byte-compare: prints per switch the arms
# whose database differs from the LAW database, and for R11U115_OFF whether EVERY arm equals
# the pristine database.
R=${1:?root}; B=${2:?bin}; L=${3:?lawtag}; P=${4:?pristag}
SRC=${SRC:-$(cd "$(dirname "$0")" && pwd)/grid}
SW="R11U115_OFF R11U115_GSOP_OFF R11U115_SYSARG_OFF R11U115_VSBARE_OFF R11U115_PVRECV_OFF R11U115_PVEXPR_OFF R11U115_NMPOOS_OFF R11U115_TPPAREN_OFF R11U115_TPIFOP_OFF R11U115_TPOUTER_OFF"
T=$(mktemp -d /tmp/r11u115_drop.XXXX)
for sw in $SW; do
  moved=0; eqp=0; n=0; list=""
  for d in $(find "$R" -name "$L.uhdm" -printf '%h\n' | sort); do
    rel=${d#$R/}; arm=${rel%/*}; form=${rel##*/}
    [ -f "$d/$P.uhdm" ] || continue
    if [ "$form" = elab ]; then oa=(--elabuhdm dut.sv --single-unit --nobuiltin); else oa=(dut.sv --single-unit --nobuiltin); fi
    (cd "$SRC/$arm" && env $sw=1 timeout 300 "$B" "${oa[@]}" -o $T/x.uhdm </dev/null >/dev/null 2>&1)
    n=$((n+1))
    cmp -s $T/x.uhdm "$d/$P.uhdm" && eqp=$((eqp+1))
    if ! cmp -s $T/x.uhdm "$d/$L.uhdm"; then moved=$((moved+1)); list="$list $rel"; fi
    rm -f $T/x.uhdm
  done
  echo "$sw arms=$n moved_vs_law=$moved equal_pristine=$eqp :$list"
done
rm -rf $T
