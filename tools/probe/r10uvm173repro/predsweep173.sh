#!/usr/bin/env bash
# r10uvm173repro/predsweep173.sh — PREDICT THE MOVER SET BY NAME, from PRISTINE
# databases only, BEFORE the patched sweep runs.  MEASUREMENT ONLY.
#
#   predsweep173.sh <pristine verify_golden workdir> <out.txt> [ct173bind]
#
# Prints one line per database that holds at least one cell this pass's gate
# would move (`COUNT WOULDMOVE` from ct173bind: a DEF-listing call bound to the
# ELABORATED twin of a function of its OWN package, written UNQUALIFIED).  The
# count is an UPPER BOUND: a call our emitter bound to the elaborated twin at
# EMISSION time never reaches the re-point loop the gate sits in, so it is
# predicted and does not move (SimpleUVM: predicted 1013, moved 1008, the five
# unrealised ones being the class-qualified static calls of § R1).
#
# A database that fails to restore is printed as RESTORE_FAIL and COUNTED — a
# driver that reaches nothing must never read as perfection.
set -u
WD=${1:?pristine workdir}
OUT=${2:?out file}
BIND=${3:-/tmp/r10uvm173_scratch/ct173bind}
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
[ -x "$BIND" ] || { echo "FATAL: no ct173bind at $BIND"; exit 3; }
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
: > "$OUT"
n=0; hit=0; fail=0
while IFS= read -r db; do
  n=$((n+1))
  rel=${db#$WD/}
  o=$("$BIND" "$db" 2>/dev/null | grep -E '^COUNT WOULDMOVE|^RESTORE_FAIL' || true)
  case "$o" in
    RESTORE_FAIL*) echo "RESTORE_FAIL $rel" >> "$OUT"; fail=$((fail+1));;
    "") ;;
    *) echo "WOULDMOVE $(echo "$o" | awk '{print $3}') $rel" >> "$OUT"; hit=$((hit+1));;
  esac
done < <(find "$WD" -name slang.uhdm | sort)
echo "-- databases scanned=$n  with-movers=$hit  restore-fail=$fail"
sort -k2,2nr "$OUT" | head -40
