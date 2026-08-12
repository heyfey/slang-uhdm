#!/usr/bin/env bash
# r10uvm60repro/census60.sh — WHOLE-CORPUS PREDICTION of § tfBodyConstArgNoFormalTs60:
# for every database a verify_golden.py sweep produced, census the CALL-ACTUAL
# cells on BOTH sides (argts60) and print one line per test naming
#
#   ourTS  = actuals of the shape the law removes that OUR side stamps
#            (scope in {CLASS_METHOD, PKG_FUNC, MOD_FUNC, TF_ORPHAN}, kind
#             constant, TS)
#   goldTS = the same cell IN GOLDEN — which must be 0 everywhere for the law to
#            be a law, and is printed so a single counterexample is visible.
#
#   usage: census60.sh <verify_golden-workdir-root> <outfile>
#
# GUARDS:
#   * the golden path is read from the test's OWN cmds.txt and the cache
#     DIRECTORY is turned into .../golden.uhdm; a missing golden prints
#     GOLDEN_MISSING and is counted, never silently skipped.
#   * a run that censuses ZERO databases is a hard error (exit 5): an empty
#     census reads exactly like "no over-fires".
set -u
WD=${1:?workdir root}
OUT=${2:?outfile}
P=${ARGTS60:-/tmp/r10uvm60/argts60}
[ -x "$P" ] || { echo "FATAL: no argts60 at $P"; exit 3; }
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
: > "$OUT"
n=0; miss=0; hits=0
tfcell='CLASS_METHOD|PKG_FUNC|MOD_FUNC|TF_ORPHAN'
while read -r db; do
  n=$((n+1))
  d=$(dirname "$db")
  G=""
  [ -f "$d/cmds.txt" ] &&
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  o=$("$P" "$db" | awk -F'\t' -v re="$tfcell" \
        '$1=="CELL" && $2 ~ re && $3=="constant" && $4=="TS" {s+=$5} END{print s+0}')
  if [ -z "$G" ] || [ ! -f "$G" ]; then
    echo "GOLDEN_MISSING ${d#$WD/} ourTS=$o" >> "$OUT"; miss=$((miss+1)); continue
  fi
  g=$("$P" "$G" | awk -F'\t' -v re="$tfcell" \
        '$1=="CELL" && $2 ~ re && $3=="constant" && $4=="TS" {s+=$5} END{print s+0}')
  if [ "$o" -gt 0 ] || [ "$g" -gt 0 ]; then
    echo "CELLHIT ${d#$WD/} ourTS=$o goldTS=$g" >> "$OUT"; hits=$((hits+1))
  fi
done < <(find "$WD" -name slang.uhdm -type f | sort)
echo "databases censused: $n   GOLDEN_MISSING: $miss   tests with a tf-body constant TS: $hits"
[ "$n" -gt 0 ] || { echo "REFUSING TO REPORT: censused nothing"; exit 5; }
grep -c GOLDEN_MISSING "$OUT" > /dev/null 2>&1 || true
sort "$OUT" | sed -n '1,80p'
