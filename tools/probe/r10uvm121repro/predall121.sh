#!/bin/bash
# r10uvm121 — run pred121 over EVERY slang.uhdm in one or more verify_golden
# workdirs and print the predicted mover set BY NAME (measurement only).
#   usage: predall121.sh <outfile> <workdir> [<workdir> ...]
set -u
OUT=${1:?outfile}; shift
HERE=$(cd "$(dirname "$0")" && pwd)
: > "$OUT"
n=0; movers=0
while IFS= read -r f <&3; do
  n=$((n+1))
  d=$(dirname "$f")
  rel=${d#*/}
  r=$("$HERE/pred121" "$f" 2>/dev/null </dev/null)
  head=$(printf '%s\n' "$r" | head -1)
  e=${head#EXACT=}; e=${e%% *}
  case "$head" in EXACT=*) ;; *) e=ERR ;; esac
  if [ "$e" != "0" ]; then
    movers=$((movers+1))
    printf 'DB\t%s\t%s\n' "$d" "$head" >> "$OUT"
    printf '%s\n' "$r" | tail -n +2 >> "$OUT"
  fi
done 3< <(for w in "$@"; do find "$w" -name slang.uhdm | sort; done)
echo "-- databases scanned: $n   PREDICTED MOVERS (EXACT>0): $movers"
echo "-- databases scanned: $n   PREDICTED MOVERS (EXACT>0): $movers" >> "$OUT"
