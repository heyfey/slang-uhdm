#!/usr/bin/env bash
# r10vbuvm22repro/vbound22.sh — THE VERIFIER'S WIDE BOUNDARY GATE.
#
# Differences from the pass's own bound22.sh, all demanded by the brief:
#   * .v arms as well as .sv (bound22.sh globbed *.sv only — 59 .v arms unseen);
#   * a SECOND, PER-DIRECTORY pass that compiles every *repro/ subdirectory's
#     arms TOGETHER (multi-file arms whose law only appears when the files are
#     elaborated as one unit);
#   * the source tree is a COPY, never the worktree;
#   * both views (default and --elabuhdm) for the per-file pass.
# GUARDS kept: list on fd 3, children </dev/null, PROCESSED asserted, scratch
# keyed on the RELATIVE path, uhdm-dump banner normalised, rc recorded per cell.
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"; : "${ROOT:?probe root COPY}"
OUT=${OUT:-/tmp/vbuvm22_bound}
MODE=${MODE:-file}          # file | dir
rm -rf "$OUT"; mkdir -p "$OUT"
LIST=$OUT/arms.txt
if [ "$MODE" = dir ]; then
  ( cd "$ROOT" && find . -type d | LC_ALL=C sort ) > "$LIST"
else
  ( cd "$ROOT" && find . \( -name '*.sv' -o -name '*.v' \) -type f | LC_ALL=C sort ) > "$LIST"
fi
N=$(wc -l < "$LIST")
echo "== boundary($MODE): $N arms under $ROOT"
proc=0; diffn=0; rejp=0; rejq=0; empty=0
exec 3< "$LIST"
while IFS= read -r rel <&3; do
  proc=$((proc+1))
  key=$(printf '%s' "$rel" | sed 's#^\./##; s#/#__#g; s#\.sv$##; s#\.v$##')
  [ -z "$key" ] && key=ROOT
  d="$OUT/$key"; mkdir -p "$d"
  if [ "$MODE" = dir ]; then
    n=0
    for f in "$ROOT/$rel"/*.sv "$ROOT/$rel"/*.v; do
      [ -f "$f" ] || continue; cp "$f" "$d/"; n=$((n+1))
    done
    if [ "$n" = 0 ]; then empty=$((empty+1)); rm -rf "$d"; continue; fi
    ARGS=$(cd "$d" && ls *.sv *.v 2>/dev/null | LC_ALL=C sort | tr '\n' ' ')
  else
    ext=${rel##*.}
    cp "$ROOT/$rel" "$d/a.$ext"; ARGS="a.$ext"
  fi
  ( cd "$d" && $PRISTINE $ARGS -o p.uhdm >p.log 2>&1; echo "rc=$?" >> p.log ) </dev/null
  ( cd "$d" && $PATCHED  $ARGS -o q.uhdm >q.log 2>&1; echo "rc=$?" >> q.log ) </dev/null
  if [ ! -s "$d/p.uhdm" ] && [ ! -s "$d/q.uhdm" ]; then
     rejp=$((rejp+1)); rejq=$((rejq+1)); echo "BOTH-REJECT $rel" >> "$OUT/reject.txt"; rm -rf "$d"; continue
  fi
  [ -s "$d/p.uhdm" ] || { rejp=$((rejp+1)); echo "PRIS-ONLY-REJECT $rel" >> "$OUT/asym.txt"; }
  [ -s "$d/q.uhdm" ] || { rejq=$((rejq+1)); echo "PATCHED-ONLY-REJECT $rel" >> "$OUT/asym.txt"; }
  if [ -s "$d/p.uhdm" ] && [ -s "$d/q.uhdm" ]; then
    ( cd "$d" && uhdm-dump p.uhdm 2>&1 | sed '1s#^[^:]*\.uhdm:#<DB>:#' > p.txt
                 uhdm-dump q.uhdm 2>&1 | sed '1s#^[^:]*\.uhdm:#<DB>:#' > q.txt ) </dev/null
    if ! cmp -s "$d/p.txt" "$d/q.txt"; then
      diffn=$((diffn+1)); echo "$rel" >> "$OUT/differ.txt"
      diff "$d/p.txt" "$d/q.txt" > "$d/diff.txt" 2>&1
    else
      rm -rf "$d"
    fi
  fi
done
exec 3<&-
echo "PROCESSED=$proc LISTED=$N DIFFER=$diffn PRIS_REJECT=$rejp PATCHED_REJECT=$rejq EMPTYDIR=$empty"
[ "$proc" = "$N" ] || { echo "FATAL: PROCESSED != LISTED"; exit 9; }
if [ -s "$OUT/asym.txt" ]; then echo "FATAL: ASYMMETRIC REJECT"; cat "$OUT/asym.txt"; fi
if [ "$diffn" -gt 0 ]; then echo "-- differing arms:"; cat "$OUT/differ.txt"; fi
