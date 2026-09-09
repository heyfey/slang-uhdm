#!/bin/bash
# r10uvm227 — THE GRID SCORER.  For every arm, runs the OFFICIAL `uhdm-cmp`
# (LHS golden, RHS ours) on the PRISTINE and on the PATCHED database that
# `grid227.sh` already BUILT for that arm, so the score is a real measurement of
# both binaries and not a −1/N artefact of a scorer that builds nothing.
# MEASUREMENT ONLY; `uhdm-cmp` is the judge.
#
#   usage: bash gscore227.sh <pristine-grid-out> <patched-grid-out>
#
# An arm whose compile FAILED on either side is printed as SKIP-RC and COUNTED:
# it teaches error recovery, not golden (uvm215's lesson).
set -u
P=${1:?pristine grid outdir}
Q=${2:?patched grid outdir}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
[ -x "$CMP" ] || { echo "FATAL: no uhdm-cmp at $CMP"; exit 3; }
printf "%-22s %10s %6s %10s %6s  %s\n" ARM PRIS_LINES HEADS PAT_LINES HEADS VERDICT
n=0; better=0; same=0; worse=0; skip=0
for d in "$P"/*/; do
    a=$(basename "$d")
    g=$P/$a/g/slpp_all/surelog.uhdm
    o1=$P/$a/o/slang.uhdm
    o2=$Q/$a/o/slang.uhdm
    n=$((n+1))
    if [ ! -f "$g" ] || [ ! -f "$o1" ] || [ ! -f "$o2" ]; then
        printf "%-22s %10s %6s %10s %6s  %s\n" "$a" - - - - "SKIP-RC(no database)"
        skip=$((skip+1)); continue
    fi
    "$CMP" "$g" "$o1" > "$P/$a/cmp.pris" 2>&1; r1=$?
    "$CMP" "$g" "$o2" > "$Q/$a/cmp.pat"  2>&1; r2=$?
    l1=$(wc -l < "$P/$a/cmp.pris"); h1=$(grep -c '^LHS:' "$P/$a/cmp.pris"; true)
    l2=$(wc -l < "$Q/$a/cmp.pat");  h2=$(grep -c '^LHS:' "$Q/$a/cmp.pat"; true)
    v="SAME (rc $r1->$r2)"
    if [ "$h2" -lt "$h1" ] || { [ "$h1" = "$h2" ] && [ "$l2" -lt "$l1" ]; }; then
        v="TO-GOLDEN (rc $r1->$r2)"; better=$((better+1))
    elif [ "$h2" -gt "$h1" ] || { [ "$h1" = "$h2" ] && [ "$l2" -gt "$l1" ]; }; then
        v="!! AWAY-GOLDEN (rc $r1->$r2)"; worse=$((worse+1))
    else
        same=$((same+1))
    fi
    printf "%-22s %10s %6s %10s %6s  %s\n" "$a" "$l1" "$h1" "$l2" "$h2" "$v"
done
echo "-- ARMS $n  TO-GOLDEN $better  SAME $same  AWAY-GOLDEN $worse  SKIP-RC $skip"
