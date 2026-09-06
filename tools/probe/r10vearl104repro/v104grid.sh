#!/usr/bin/env bash
# r10v104 VERIFIER GRID -- MEASUREMENT ONLY, independent of the pass's cen104.
#   OURS_BIN=<binary> bash v104grid.sh <outdir> <arm.sv> ...
set -u
OURS=${OURS_BIN:?set OURS_BIN}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
DUMP=$HOME/.local/bin/uhdm-dump
OUT=${1:?outdir}; shift
mkdir -p "$OUT"
printf '%-18s %6s %6s %8s %6s\n' ARM SLRC OURRC CMPLINES HEADS
for f in "$@"; do
  arm=$(basename "$f" .sv)
  d="$OUT/$arm"; mkdir -p "$d"
  $SL -parse -elabuhdm -nobuiltin -nocache -mt 0 -mp 0 -d uhdm -o "$d/sl" "$f" > "$d/sl.log" 2>&1 </dev/null
  slrc=$?
  G=$(find "$d/sl" -name '*.uhdm' 2>/dev/null | head -1)
  F=$(readlink -f "$f"); ( cd "$d" && "$OURS" --elabuhdm "$F" --nobuiltin -o ours.uhdm > ours.log 2>&1 </dev/null )
  ourc=$?
  if [ -z "${G:-}" ] || [ ! -f "$G" ] || [ ! -f "$d/ours.uhdm" ]; then
    printf '%-18s %6s %6s %8s %6s  REJECT\n' "$arm" "$slrc" "$ourc" - -
    continue
  fi
  L=$($CMP "$G" "$d/ours.uhdm" 2>/dev/null | wc -l)
  H=$($CMP "$G" "$d/ours.uhdm" 2>&1 >/dev/null | grep -c '^LHS:' || true)
  $DUMP "$G" > "$d/g.dump" 2>&1
  $DUMP "$d/ours.uhdm" > "$d/o.dump" 2>&1
  python3 "$(dirname "$0")/pacen.py" "$d/g.dump" > "$d/g.cen" 2>"$d/g.cen.err"
  python3 "$(dirname "$0")/pacen.py" "$d/o.dump" > "$d/o.cen" 2>"$d/o.cen.err"
  printf '%-18s %6s %6s %8s %6s\n' "$arm" "$slrc" "$ourc" "$L" "$H"
done
