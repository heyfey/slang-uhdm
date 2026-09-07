#!/usr/bin/env bash
# r10v190 verifier arm driver.  MEASUREMENT ONLY; uhdm-cmp is the judge.
#   vgrid.sh <file.sv> <binA:pristine> <binB:patched> <workdir>
# Builds ONE REAL Surelog golden per view and both binaries' databases, records
# EVERY rc (an rc=139 must never read as a result), and runs the DEEP census.
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
CEN=${VCEN:-/tmp/v190_scratch/ctv190cen}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; echo "rc=$? $*" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"
  run "$B" "$SV" $EF -o "$W/b_$v.uhdm"
  for pair in "g_$v/slpp_all/surelog.uhdm:cen.g.$v.txt" "a_$v.uhdm:cen.a.$v.txt" "b_$v.uhdm:cen.b.$v.txt"; do
    f=${pair%%:*}; out=${pair#*:}
    if [ -f "$W/$f" ]; then
      "$CEN" "$W/$f" "$v" > "$W/$out" 2>>"$W/cen.err"
      echo "cen rc=$? $f rows=$(wc -l < "$W/$out")" >> "$W/cmds.txt"
    else : > "$W/$out"; echo "cen MISSING $f" >> "$W/cmds.txt"; fi
  done
  for s in a b; do
    if [ -f "$W/g_$v/slpp_all/surelog.uhdm" ] && [ -f "$W/${s}_$v.uhdm" ]; then
      "$CMP" "$W/g_$v/slpp_all/surelog.uhdm" "$W/${s}_$v.uhdm" > "$W/cmp.$s.$v.txt" 2>&1
      echo "cmp rc=$? $s $v lines=$(wc -l < "$W/cmp.$s.$v.txt") heads=$(grep -c '^LHS:' "$W/cmp.$s.$v.txt"; true)" >> "$W/cmds.txt"
    else echo "cmp MISSING $s $v" >> "$W/cmds.txt"; fi
  done
done
cat "$W"/cen.g.*.txt > "$W/g.cen"; cat "$W"/cen.a.*.txt > "$W/a.cen"; cat "$W"/cen.b.*.txt > "$W/b.cen"
echo "--- nonzero rcs:"; grep '^rc=' "$W/cmds.txt" | grep -v '^rc=0 '; true
echo "--- cmp:"; grep -E '^cmp ' "$W/cmds.txt"; true
echo "--- binaries in cmds.txt:"; grep -o "$A\|$B" "$W/cmds.txt" | sort | uniq -c
for v in def elab; do
  if [ -f "$W/a_$v.uhdm" ] && [ -f "$W/b_$v.uhdm" ]; then
    if cmp -s "$W/a_$v.uhdm" "$W/b_$v.uhdm"; then echo "$v IDENTICAL"; else echo "$v DIFFER"; fi
  fi
done
