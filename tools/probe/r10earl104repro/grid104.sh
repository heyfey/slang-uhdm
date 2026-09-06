#!/usr/bin/env bash
# r10earl104 GRID DRIVER -- MEASUREMENT ONLY.
#   OURS_BIN=<binary> bash grid104.sh <outdir> [<arm.sv> ...]
# For every arm x {plain, elab}: build the Surelog GOLDEN here, build OURS with
# the named binary, run cen104 --all on the pair.  The uhdm-cmp line/head count
# is printed beside the census verdict; the CENSUS is what the law is written
# from, the official uhdm-cmp is the judge.
#
# GUARDS: every producer's rc is recorded; a missing database is printed as
# REJECT and COUNTED, never silently skipped; children get </dev/null so no
# child can eat the arm list.
set -u
OURS=${OURS_BIN:?set OURS_BIN}
CEN=${CEN_BIN:-/tmp/r10earl104_cen104}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=${1:?outdir}; shift
mkdir -p "$OUT"
FILES=("$@")
[ ${#FILES[@]} -eq 0 ] && FILES=("$HERE"/g?_*104.sv)
printf '%-18s %-6s %6s %6s %8s %6s  %s\n' ARM VIEW SLRC OURRC CMPLINES HEADS CENSUS
for f0 in "${FILES[@]}"; do
  f=$f0; case "$f" in /*) ;; *) f="$HERE/$f0";; esac
  [ -f "$f" ] || continue
  arm=$(basename "$f" .sv)
  for view in plain elab; do
    case $view in plain) SLF="-parse"; SUF="";; elab) SLF="-parse -elabuhdm"; SUF="--elabuhdm";; esac
    d="$OUT/${arm}_${view}"; mkdir -p "$d"
    $SL $SLF -nobuiltin -nocache -mt 0 -mp 0 -d uhdm -o "$d/sl" "$f" > "$d/sl.log" 2>&1 </dev/null
    slrc=$?
    G=$(find "$d/sl" -name '*.uhdm' 2>/dev/null | head -1)
    ( cd "$d" && "$OURS" $SUF "$f" --nobuiltin -o ours.uhdm > ours.log 2>&1 </dev/null )
    ourc=$?
    if [ -z "${G:-}" ] || [ ! -f "$G" ] || [ ! -f "$d/ours.uhdm" ]; then
      printf '%-18s %-6s %6s %6s %8s %6s  %s\n' "$arm" "$view" "$slrc" "$ourc" - - REJECT
      continue
    fi
    L=$($CMP "$G" "$d/ours.uhdm" 2>/dev/null | wc -l)
    H=$($CMP "$G" "$d/ours.uhdm" 2>&1 >/dev/null | grep -c '^LHS:' || true)
    "$CEN" "$G" "$d/ours.uhdm" --all > "$d/cen.txt" 2>&1
    cp "$G" "$d/golden.uhdm" 2>/dev/null
    V=$(grep -m1 '^SUMMARY' "$d/cen.txt")
    printf '%-18s %-6s %6s %6s %8s %6s  %s\n' "$arm" "$view" "$slrc" "$ourc" "$L" "$H" "$V"
  done
done
