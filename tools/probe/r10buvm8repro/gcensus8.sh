#!/usr/bin/env bash
# r10buvm8 — CENSUS-PREDICT: every golden database in the cache, counting the
# func_call arguments that carry a ref_typespec.  GOLDEN-VS-GOLDEN FIRST: this
# is the LHS-only side of the join and it says how many cells the law must
# produce corpus-wide before a single line of emitter code is written.
#   * `.tmp*` cache dirs are SKIPPED: they are half-written duplicates of a
#     real entry and would double-count.
#   * a per-file timeout is enforced so one 500 MB giant cannot eat the budget,
#     and a timed-out file is COUNTED as TIMEOUT, never as zero.
set -u
OUT=${1:?out}
: > "$OUT"
n=0; to=0
for d in "$HOME"/.cache/slang-uhdm-goldens/*/; do
  case "$d" in *.tmp*) continue;; esac
  f=$d/golden.uhdm
  [ -f "$f" ] || continue
  h=$(basename "$d")
  if timeout 240 /tmp/r10buvm8cen "$f" "$h" 2>/dev/null | grep -E '^(TOTALS|CELL)' >> "$OUT"; then
    n=$((n+1))
  else
    echo "TIMEOUT_OR_FAIL $h" >> "$OUT"; to=$((to+1))
  fi
done
echo "GCENSUS done files=$n timeout_or_fail=$to -> $OUT"
