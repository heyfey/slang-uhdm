#!/bin/bash
# r10v212 (VERIFIER) — run the FILLS ledger over EVERY comparable row of a
# verify_golden workdir.  MEASUREMENT ONLY; `uhdm-cmp` is the sole judge.
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# The pass under verification only ever CLEARS a class_typespec's
# `Parameters`/`Param_assigns`, so the ONE regression shape is a listing golden
# has that ours loses.  This walks every row directory, resolves the GOLDEN
# database from that row's own `cmds.txt` (the cache line names the cache dir;
# otherwise the row's own surelog output is used), and prints the ledger.
#
# GUARDS: the row list is read on fd 3 with children `</dev/null`; PROCESSED is
# asserted against LISTED; a run that reaches no row exits 4 instead of printing
# green; rows whose golden database is missing are counted as NOGOLD and named,
# never silently skipped.
#
#   usage: FILLS=<ctv212fills> fillsweep212.sh <workdir> <out.txt>
set -u
FILLS=${FILLS:?set FILLS to the built ctv212fills}
WD=$(readlink -f "${1:?workdir}")
OUTF=${2:?out file}
[ -x "$FILLS" ] || { echo "FATAL: $FILLS not executable"; exit 3; }
LIST=$(mktemp /tmp/v212_fillsweep.XXXXXX)
find "$WD" -name slang.uhdm | sort > "$LIST"
listed=$(grep -c . "$LIST" || true)
echo "LISTED=$listed" | tee "$OUTF"
[ "$listed" -gt 0 ] || { echo "GATE FAIL: no databases under $WD" | tee -a "$OUTF"; exit 4; }
proc=0; nogold=0; lost=0; extra=0; sized=0; rows=0
while read -r db <&3; do
  d=$(dirname "$db")
  g=""
  if [ -f "$d/cmds.txt" ]; then
    c=$(sed -n 's/^surelog: (golden cache hit \(.*\))$/\1/p' "$d/cmds.txt" | head -1)
    [ -n "$c" ] && [ -f "$c/golden.uhdm" ] && g="$c/golden.uhdm"
  fi
  if [ -z "$g" ]; then
    g=$(ls "$d"/slpp_all/*.uhdm "$d"/slpp_unit/*.uhdm 2>/dev/null | head -1)
  fi
  if [ -z "$g" ] || [ ! -f "$g" ]; then
    nogold=$((nogold+1)); echo "NOGOLD ${d#$WD/}" >> "$OUTF"; proc=$((proc+1)); continue
  fi
  out=$("$FILLS" "$g" "$db" 2>&1 </dev/null)
  line=$(echo "$out" | sed -n '2p')
  l=$(echo "$line" | sed -n 's/^FILL_LOST=\([0-9]*\).*/\1/p')
  e=$(echo "$line" | sed -n 's/.*FILL_EXTRA=\([0-9]*\).*/\1/p')
  z=$(echo "$line" | sed -n 's/.*FILL_SIZE=\([0-9]*\).*/\1/p')
  l=${l:-0}; e=${e:-0}; z=${z:-0}
  lost=$((lost+l)); extra=$((extra+e)); sized=$((sized+z)); rows=$((rows+1))
  if [ "$l" != 0 ] || [ "$e" != 0 ] || [ "$z" != 0 ]; then
    echo "ROW ${d#$WD/}  $line" >> "$OUTF"
    echo "$out" | grep -E '^(LOST|EXTRA|SIZE) ' >> "$OUTF"
  fi
  proc=$((proc+1))
done 3< "$LIST"
rm -f "$LIST"
echo "PROCESSED=$proc LISTED=$listed SCORED_ROWS=$rows NOGOLD=$nogold TOTAL_FILL_LOST=$lost TOTAL_FILL_EXTRA=$extra TOTAL_FILL_SIZE=$sized" | tee -a "$OUTF"
[ "$proc" = "$listed" ] || { echo "GATE FAIL: PROCESSED != LISTED" | tee -a "$OUTF"; exit 4; }
