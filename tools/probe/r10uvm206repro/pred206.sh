#!/usr/bin/env bash
# r10uvm206 — pred206.sh — MEASUREMENT ONLY.  Runs ct206pred over every
# slang.uhdm of a PRISTINE verify_golden workdir and prints the MOVER
# PREDICTION (an upper bound; see ct206pred.cpp's header) BY NAME, before the
# patched sweep exists.
#   usage: PRED=<ct206pred> ./pred206.sh <workdir> <out>
set -u
PRED=${PRED:?}; WD=${1:?workdir}; OUT=${2:?out}
[ -x "$PRED" ] || { echo "FATAL: no ct206pred at $PRED"; exit 3; }
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
: > "$OUT"
n=0; maybe=0
while IFS= read -r f; do
  d=$(dirname "$f")
  # <workdir>/<mode>/<Name>-<hash>/slang.uhdm  ->  <mode>/<Name>
  rel=${d#"$WD"/}
  mode=${rel%%/*}; nm=${rel#*/}; nm=${nm%-*}
  line=$("$PRED" "$f" 2>/dev/null | head -1)
  [ -n "$line" ] || line="NOREAD"
  echo "$nm $mode $line" >> "$OUT"
  n=$((n+1))
  case "$line" in MAYBE*) maybe=$((maybe+1));; esac
done < <(find "$WD" -name slang.uhdm | sort)
echo "-- SCANNED=$n MAYBE=$maybe CLEAN=$((n-maybe))" >> "$OUT"
grep -E '^[^ ]+ [^ ]+ MAYBE' "$OUT" | awk '{print $1, $2}' | sort -u | sed 's/^/-- PREDICTED-MOVER /' >> "$OUT"
# The listing NAMES every row of the workdir, so redact the slang-fenced four
# before the file becomes an artifact (scrub206.sh reads the fence list out of
# canaudit.sh and never spells it; canaudit's FENCE-BREACH counter is the check).
bash "$(dirname "$0")/scrub206.sh" "$OUT" > /dev/null
tail -40 "$OUT"
