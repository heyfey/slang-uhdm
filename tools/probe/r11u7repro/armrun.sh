#!/bin/bash
# r11u7 arm runner.  usage: armrun.sh <armdir> <tag> <slang-binary> [mode]
# Builds the REAL v1.87 golden with Surelog in <armdir>/w_<tag>, our database
# with the named binary, dumps both, runs the official uhdm-cmp, and records
# EVERY rc.  mode: `plain` (default, Surelog `-parse -nobuiltin -nocache -sv`,
# slang `--single-unit --nobuiltin`) or `elab` (adds -elabuhdm / --elabuhdm).
set -u
A=$(readlink -f "${1:?arm dir}"); T=${2:?tag}; B=$(readlink -f "${3:?binary}")
M=${4:-plain}
SU=${SU:-/home/heyfey/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${CMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp}
W="$A/w_$T"; rm -rf "$W"; mkdir -p "$W"
SRC=$(cd "$A" && ls *.sv 2>/dev/null | tr '\n' ' ')
[ -n "$SRC" ] || { echo "$T: NO SOURCES in $A"; exit 2; }
SUX=""; SLX="--single-unit --nobuiltin"
[ "$M" = elab ] && { SUX="-elabuhdm"; SLX="--elabuhdm --nobuiltin"; }
( cd "$W" && "$SU" -parse -nobuiltin -nocache -sv $SUX $(for s in $SRC; do echo "$A/$s"; done) > su.log 2>&1 )
surc=$?
G="$W/slpp_all/surelog.uhdm"
( cd "$A" && "$B" $SRC $SLX -o "$W/slang.uhdm" > "$W/sl.log" 2>&1 )
slrc=$?
err=$(grep -c '^\[  ERROR\] : 0' "$W/slpp_all/surelog.log" 2>/dev/null; true)
"$DUMP" "$G"            > "$W/golden.dump" 2>/dev/null
"$DUMP" "$W/slang.uhdm" > "$W/ours.dump"   2>/dev/null
"$CMP" "$G" "$W/slang.uhdm" > "$W/cmp.out" 2> "$W/cmp.err"
cmprc=$?
nl=$(grep -c '^LHS:' "$W/cmp.err" 2>/dev/null; true)
printf '%s/%s/%s  surelog_rc=%s ERROR0=%s slang_rc=%s cmp_rc=%s LHSheads=%s cmplines=%s goldenbytes=%s oursbytes=%s\n' \
  "$(basename "$A")" "$T" "$M" "$surc" "$err" "$slrc" "$cmprc" "$nl" \
  "$(wc -l < "$W/cmp.err")" \
  "$(stat -c%s "$G" 2>/dev/null || echo NONE)" "$(stat -c%s "$W/slang.uhdm" 2>/dev/null || echo NONE)"
