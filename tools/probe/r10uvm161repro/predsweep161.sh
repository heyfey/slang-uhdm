#!/usr/bin/env bash
# r10uvm161repro/predsweep161.sh — run the a-priori predictor over EVERY
# database of a verify_golden workdir and name the mover set BY NAME, from the
# PRISTINE databases only, before any patched database exists (RESUME.md §6).
# MEASUREMENT ONLY.
#   predsweep161.sh <pristine workdir> <ct161pred> <out file>
# Prints one line per row that holds at least one predictable cell, then the
# totals.  A database that fails to restore is printed as RESTORE_FAIL and
# COUNTED — a sweep that reaches nothing must never read as "no movers".
set -u
WD=${1:?workdir}
PRED=${2:?ct161pred}
OUT=${3:?out}
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
[ -x "$PRED" ] || { echo "FATAL: no predictor $PRED"; exit 3; }
: > "$OUT"
n=0; fail=0; rows=0
while IFS= read -r f; do
  n=$((n+1))
  d=$(dirname "$f")
  row="$(basename "$(dirname "$d")")/$(basename "$d")"     # <mode>/<test>
  out=$("$PRED" "$f" "$row" 2>>"$OUT.err")
  rc=$?
  if [ $rc -ne 0 ] || printf '%s' "$out" | grep -q RESTORE_FAIL; then
    echo "RESTORE_FAIL $row rc=$rc" >> "$OUT"; fail=$((fail+1)); continue
  fi
  t=$(printf '%s' "$out" | sed -n 's/^TOTAL\t[^\t]*\t\([0-9]*\)$/\1/p' | tail -1)
  [ -z "$t" ] && t=0
  if [ "$t" -gt 0 ]; then
    printf '%s' "$out" | grep -E '^(PRED|TOTAL)' >> "$OUT"
    rows=$((rows+1))
  fi
done < <(find "$WD" -name slang.uhdm | sort)
echo "-- databases=$n  rows-with-cells=$rows  restore-fail=$fail" | tee -a "$OUT"
grep -c '^PRED' "$OUT" | sed 's/^/-- predicted cells: /' | tee -a "$OUT"
grep '^TOTAL' "$OUT" | awk -F'\t' '{print $2}' | sort -u | sed 's/^/-- MOVER ROW: /' | tee -a "$OUT"
