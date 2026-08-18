#!/usr/bin/env bash
# r10earl69 — THE CORPUS FENCE SCAN for § hpNameBareIdxFold69.
# Runs the hier_path NAME census + the rewrite MIRROR (hpfold69.py) over every
# .uhdm under a root and reports, per database, how many hier_path names the
# rewrite would change.  Run it over BOTH the pristine sweep workdirs (which
# databases can move) and the whole golden cache (golden must be a FIXED POINT).
# MEASUREMENT ONLY.
#   usage: HPNAME=/abs/hpname69 fencescan69.sh <root> <out.txt>
set -u
HP=${HPNAME:?set HPNAME to the built hpname69}
MIR=$(dirname "$0")/hpfold69.py
R=${1:?root}
OUT=${2:?out}
: > "$OUT"
find "$R" -name '*.uhdm' -print0 | sort -z | while IFS= read -r -d '' f; do
  n=$("$HP" "$f" 2>/dev/null | python3 "$MIR" | head -1)
  echo "$f $n" >> "$OUT"
done
awk '{t+=$3; c+=$5} END{printf "DBS %d HIER_PATHS %d WOULD-CHANGE %d\n", NR, t, c}' "$OUT"
