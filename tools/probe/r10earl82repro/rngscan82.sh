#!/usr/bin/env bash
# r10earl82 — CORPUS-WIDE RANGE-BOUND SCAN.  MEASUREMENT ONLY: it READS the
# databases a sweep already produced and DISPATCHES NOTHING, so no test —
# fenced or otherwise — is run by it.  The four slang-fenced tests appear in
# the FENCED= line and nowhere else.
#
#   usage: RNGCEN=<rngcen82> [FENCE_RE=<alternation>] \
#              rngscan82.sh <workdir> <outdir> [<name-regex>]
#
# FENCE_RE is the campaign's slang-FENCED test list, supplied by the OPERATOR at
# run time (RESUME.md §1 names it) and never written down here: a probe artifact
# that spells those names is a FENCE-BREACH to `canaudit.sh`.  The measurements
# in this directory were taken with that list passed in, and every matching test
# is skipped by NAME and counted on the FENCED= line.  The scanner READS
# databases and DISPATCHES NOTHING, so no test is run either way.
#
# For every <mode>/<test>-<hash>/ in the workdir it censuses OURS
# (`slang.uhdm`) and GOLDEN (the cache path named in that test's OWN
# `cmds.txt` — never a guessed one) and writes
#   <outdir>/<mode>.<test>.ours.cen  /  .gold.cen
# skipping any pair where either side is missing (counted, never silent).
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; PAT=${3:-}
CEN=${RNGCEN:?set RNGCEN}
FENCED=${FENCE_RE:-}
mkdir -p "$OUT" || exit 1
done_n=0; miss=0; fenced=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    b=$(basename "$d"); n=${b%-*}
    if [ -n "$FENCED" ] && printf '%s' "$n" | grep -qxE "$FENCED"; then
      fenced=$((fenced+1)); continue
    fi
    [ -n "$PAT" ] && { printf '%s' "$n" | grep -qE "$PAT" || continue; }
    O=$d/slang.uhdm; C=$d/cmds.txt
    G=""
    [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then miss=$((miss+1)); continue; fi
    "$CEN" "$O" > "$OUT/$mode.$n.ours.cen" 2>/dev/null
    "$CEN" "$G" > "$OUT/$mode.$n.gold.cen" 2>/dev/null
    done_n=$((done_n+1))
  done
done
echo "SCANNED=$done_n  SKIP-NOFILE=$miss  FENCED=$fenced"
