#!/usr/bin/env bash
# r10sd10 — run ct10pred over EVERY database a verify_golden sweep produced, in
# the mode that makes the number a PREDICTION: on the PRISTINE workdir, before
# any delivered database has been compared.
#
#   usage: CT10PRED=/tmp/r10sd10_pred ./ct10scan.sh <workdir-root> [jobs]
#
# The golden for each database is read out of that run's own `cmds.txt`
# (`surelog: (golden cache hit <dir>)`), so the pairing is the harness's own and
# not a guess.  A database whose cmds.txt names no cache entry is reported as
# NO_GOLDEN and COUNTED — a silently skipped row is how a scan reads clean.
#
# GUARD (measure the measurer): zero databases scanned is exit 5.
set -u
WD=${1:?workdir root}
J=${2:-2}
PRED=${CT10PRED:-/tmp/r10sd10_pred}
[ -x "$PRED" ] || { echo "FATAL: no ct10pred at $PRED"; exit 3; }
export PRED WD
one() {
  db=$1
  d=$(dirname "$db")
  g=$(sed -n 's/.*golden cache hit \([^)]*\)).*/\1/p' "$d/cmds.txt" 2>/dev/null | head -1)
  if [ -z "$g" ] || [ ! -f "$g/golden.uhdm" ]; then
    echo "NO_GOLDEN ${db#$WD/}"
    return
  fi
  # A database whose join with its golden is EMPTY prints `[S] KINDS shared=0`
  # and nothing else.  It is an OUTCOME, not a parse failure: matching on the
  # BUCKET FIELD rather than on the line prefix keeps a legitimately empty
  # database out of the arithmetic below, which is where the first version of
  # this script died — one `$(( ))` syntax error killed the whole loop after
  # 687 of 1358 databases, and the accounting guard at the bottom is the only
  # reason that was not reported as a clean scan.
  line=$("$PRED" "$g/golden.uhdm" "$db" 2>/dev/null | grep 'G_CLASSVAR=')
  [ -n "$line" ] || { echo "NO_LINE ${db#$WD/}"; return; }
  gc=$(echo "$line" | sed -E 's/.*G_CLASSVAR=([0-9]+).*/\1/')
  gr=$(echo "$line" | sed -E 's/.*G_REFVAR=([0-9]+).*/\1/')
  oc=$(echo "$line" | sed -E 's/.*O_CLASSVAR=([0-9]+).*/\1/')
  orv=$(echo "$line" | sed -E 's/.*O_REFVAR=([0-9]+).*/\1/')
  tot=$((gc + gr + oc + orv))
  [ "$tot" -gt 0 ] && echo "CAND ${db#$WD/} G_CLASSVAR=$gc G_REFVAR=$gr O_CLASSVAR=$oc O_REFVAR=$orv"
  echo "SCANNED ${db#$WD/}"
}
export -f one
T=/tmp/r10sd10_scan.$$
: > "$T"
find "$WD" -name slang.uhdm -type f | sort > "$T.list"
total=$(wc -l < "$T.list")
# `one` is run with its stdin CLOSED: a child that reads stdin eats the very
# list this loop is reading, and the first version of this script silently
# scanned 687 of 1358 databases because of it.  The accounting guard below is
# what caught that, which is why it is a hard error and not a warning.
while IFS= read -r db; do one "$db" < /dev/null; done < "$T.list" >> "$T" 2>&1
n=$(grep -c '^SCANNED' "$T" || true)
nog=$(grep -c '^NO_GOLDEN' "$T" || true)
nol=$(grep -c '^NO_LINE' "$T" || true)
grep '^CAND' "$T" | LC_ALL=C sort
cand=$(grep -c '^CAND' "$T" || true)
rows=$(grep '^CAND' "$T" |
       sed -E 's/.*G_CLASSVAR=([0-9]+) G_REFVAR=([0-9]+) O_CLASSVAR=([0-9]+) O_REFVAR=([0-9]+)/\1 \2 \3 \4/' |
       awk '{a+=$1;b+=$2;c+=$3;d+=$4} END{printf "G_CLASSVAR=%d G_REFVAR=%d O_CLASSVAR=%d O_REFVAR=%d", a+0,b+0,c+0,d+0}')
echo "[S] databases=$total accounted=$((n + nog + nol)) scanned=$n no_golden=$nog no_line=$nol candidates=$cand $rows"
rm -f "$T" "$T.list"
# MEASURE THE MEASURER: every database found must be accounted for by exactly
# one of the three outcomes, and a scan of nothing is never a clean scan.
[ "$total" -gt 0 ] || { echo "REFUSING TO REPORT: no databases scanned"; exit 5; }
[ "$((n + nog + nol))" = "$total" ] || {
  echo "REFUSING TO REPORT: $((total - n - nog - nol)) databases produced no verdict"; exit 6; }
