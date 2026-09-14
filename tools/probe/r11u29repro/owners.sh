#!/bin/bash
# r11u29repro/owners.sh — name the OWNER behind an `RHS: <null>` head.
#
# An `RHS: <null>` head names the POINTEE (the object golden's edge points AT),
# never the owner that holds the edge (RESUME.md 9).  r10earl60repro/tsinst60
# finds the owner by masking candidates into a fresh CompareContext and
# re-running the OFFICIAL design::Compare.  This driver just feeds it the rows.
#
# It runs --calib (golden vs ITSELF) first for every row: a calibration that
# reports a head would mean the locator is lying, and the row is skipped.
#
#   usage: owners.sh <workdir> <mode> <outdir> <name> [<name> ...]
#   env:   TSINST=<path to the built tsinst60>   (default /tmp/r11u29_scratch/tsinst60)
set -u
WD=${1:?workdir}; MODE=${2:?mode}; OUT=${3:?outdir}; shift 3
T=${TSINST:-/tmp/r11u29_scratch/tsinst60}
[ -x "$T" ] || { echo "FATAL: no tsinst60 at $T"; exit 3; }
mkdir -p "$OUT"
for n in "$@"; do
  for d in "$WD/$MODE/$n"-*/; do
    [ -d "$d" ] || continue
    C=$d/cmds.txt
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    O=$d/slang.uhdm
    if [ ! -f "${G:-/nonexistent}" ] || [ ! -f "$O" ]; then
      echo "$n SKIP-NOFILE"; continue
    fi
    "$T" "$G" "$G" --calib > "$OUT/$n.calib.txt" 2>&1
    if grep -qi 'head' "$OUT/$n.calib.txt" && ! grep -qi 'NO HEAD\|no head' "$OUT/$n.calib.txt"; then
      echo "$n CALIB-DIRTY (see $OUT/$n.calib.txt)"; continue
    fi
    timeout 900 "$T" "$G" "$O" > "$OUT/$n.owner.txt" 2>&1
    echo "$n rc=$? :: $(grep -E 'OWNER|POOL-INERT|NOT-SINGLE|LOCATED' "$OUT/$n.owner.txt" | head -3 | tr '\n' ' ')"
  done
done
