#!/usr/bin/env bash
# r10uvm177repro/predsweep177.sh — PREDICT the mover set BY NAME from PRISTINE
# databases, BEFORE the patched sweep runs (RESUME.md §6 gate 5).
# MEASUREMENT ONLY; the official uhdm-cmp is the sole judge.
#
#   predsweep177.sh <pristine verify_golden workdir> <out.txt> [<ct177pred>]
#
# Walks every `slang.uhdm` under the workdir, runs ct177pred on it, and prints
# one line per database that holds at least one candidate return variable, with
# the candidate count and the candidate rows.  A database with ZERO candidates
# CANNOT move under § ownNamedAliasRetIsRefVar177; a database listed here MAY
# move (the DB-side predicate is a deliberate superset — see ct177pred.cpp).
set -u
WD=${1:?workdir}
OUT=${2:?out}
PRED=${3:-/tmp/r10uvm177_ct177pred}
[ -x "$PRED" ] || { echo "FATAL: no ct177pred at $PRED"; exit 3; }
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
: > "$OUT"
n=0; hit=0
while IFS= read -r f; do
  n=$((n+1))
  rel=${f#"$WD"/}
  out=$("$PRED" "$f" 2>/dev/null)
  c=$(printf '%s\n' "$out" | sed -n 's/^CANDS=//p')
  [ -n "${c:-}" ] || c=0
  if [ "$c" != "0" ]; then
    hit=$((hit+1))
    echo "DB $rel CANDS=$c" >> "$OUT"
    printf '%s\n' "$out" | grep '^CAND' >> "$OUT"
  fi
done < <(find "$WD" -name slang.uhdm | sort)
echo "SCANNED=$n  DBS-WITH-CANDIDATES=$hit" | tee -a "$OUT"
