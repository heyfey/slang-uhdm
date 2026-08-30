#!/usr/bin/env bash
# r10earl102 GRID DRIVER -- MEASUREMENT ONLY.
#   OURS_BIN=<binary> bash grid102.sh <outdir> [<arm.sv> ...]
# For every arm x {plain, elab}: build the Surelog GOLDEN here, build OURS with
# the named binary, run ct102cen on both and join them with cen102.py.  The
# uhdm-cmp line/head count is printed beside the census verdict; the CENSUS is
# what the law is written from, uhdm-cmp is the judge.
#
# GUARDS: rc of every producer is recorded; a missing database is printed as
# REJECT and COUNTED, never silently skipped; the file list is read on fd 3 and
# children get </dev/null.
set -u
OURS=${OURS_BIN:?set OURS_BIN}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=${1:?outdir}; shift
mkdir -p "$OUT"
FILES=("$@")
[ ${#FILES[@]} -eq 0 ] && FILES=("$HERE"/g?_*102.sv)
printf '%-16s %-6s %6s %6s %8s %6s  %s\n' ARM VIEW SLRC OURRC CMPLINES HEADS CENSUS
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
      printf '%-16s %-6s %6s %6s %8s %6s  %s\n' "$arm" "$view" "$slrc" "$ourc" - - REJECT
      continue
    fi
    L=$($CMP "$G" "$d/ours.uhdm" 2>/dev/null | wc -l)
    H=$($CMP "$G" "$d/ours.uhdm" 2>&1 >/dev/null | grep -c '^LHS:' || true)
    "$HERE/ct102cen" "$G"            > "$d/cen.gold.txt" 2>&1
    "$HERE/ct102cen" "$d/ours.uhdm"  > "$d/cen.ours.txt" 2>&1
    python3 "$HERE/cen102.py" "$d/cen.gold.txt" "$d/cen.ours.txt" > "$d/cen.join.txt" 2>&1
    V=$(grep -m1 '^BOTH-SAME' "$d/cen.join.txt")
    printf '%-16s %-6s %6s %6s %8s %6s  %s\n' "$arm" "$view" "$slrc" "$ourc" "$L" "$H" "$V"
  done
done
