#!/usr/bin/env bash
# r10uvm174repro/predsweep174.sh — name the mover set BY NAME from PRISTINE
# databases, BEFORE the patched sweep runs.  MEASUREMENT ONLY.
#   predsweep174.sh <pristine verify_golden workdir> <out file> [<ct174pred>]
#
# Two numbers per database, bracketing the truth from opposite sides:
#   WINDOWS     out-of-body class-method clones the DEF package listings carry.
#               The law can only move a cell inside one, so WINDOWS=0 PROVES a
#               database cannot move.  POSSIBLE movers.
#   CANDIDATES  folded-`$bits` constants found inside those windows.  Tighter,
#               but it misses a cell whose constant hangs off an unparented
#               carrier (a `+: $bits(byte)` part-select width).  PREDICTED
#               movers.
# Databases that fail to restore are printed, not swallowed.
set -u
WD=${1:?workdir}
OUT=${2:?out}
PRED=${3:-/tmp/r10uvm174_ct174pred}
[ -x "$PRED" ] || { echo "FATAL: no ct174pred at $PRED"; exit 3; }
: > "$OUT"
n=0; hit=0; win=0; fail=0
while IFS= read -r db; do
  n=$((n+1))
  r=$("$PRED" "$db" 2>/dev/null | head -1)
  case "$r" in
    CANDIDATES\ *\ WINDOWS\ *)
      c=$(echo "$r" | awk '{print $2}'); w=$(echo "$r" | awk '{print $4}')
      [ "$w" != 0 ] && { win=$((win+1)); echo "WINDOW w=$w c=$c $db" >> "$OUT"; }
      [ "$c" != 0 ] && { hit=$((hit+1)); echo "MOVER c=$c w=$w $db" >> "$OUT"; }
      ;;
    *) fail=$((fail+1)); echo "SCANFAIL $db ($r)" >> "$OUT" ;;
  esac
done < <(find "$WD" -name slang.uhdm | sort)
echo "SCANNED=$n POSSIBLE(WINDOWS>0)=$win PREDICTED_MOVERS=$hit SCANFAIL=$fail" | tee -a "$OUT"
