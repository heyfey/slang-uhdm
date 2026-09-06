#!/bin/bash
# r10uvm171 — CORPUS-WIDE CANDIDATE SCAN.  MEASUREMENT ONLY.
#
# Walks a verify_golden workdir, and for EVERY row runs ct171list on the pair
# (golden, ours), so both one-sided sets are visible: the objects golden binds
# and we do not (what the law must MOVE) and the objects we bind and golden
# does not (what it must never mint).  The two listings are printed per row and
# never merged into one multiset (r10v169's listcheck law).
#
# GUARDS: the golden path is read out of the row's OWN cmds.txt and the cache
# DIRECTORY is turned into .../golden.uhdm (handing a directory to a restore
# reads nothing); a row missing either side prints SKIP and is COUNTED, so a
# scan that reaches nothing can never read as "no candidates".
#
#   usage: predsweep171.sh <workdir> <out.txt>
set -u
WD=${1:?workdir}
OUT=${2:?out}
LIST=${CT171LIST:-/tmp/r10uvm171_ct171list}
[ -x "$LIST" ] || { echo "FATAL: no ct171list at $LIST"; exit 3; }
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
: > "$OUT"
rows=0; skip=0; hit=0
for d in "$WD"/*/*/; do
  C=$d/cmds.txt
  O=$d/slang.uhdm
  [ -f "$C" ] || continue
  rows=$((rows+1))
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
    echo "SKIP $d" >> "$OUT"; skip=$((skip+1)); continue
  fi
  T=$("$LIST" "$G" "$O" 2>&1)
  # A row with no candidate on EITHER side prints two "(0 rows)" lines.
  if [ "$(printf '%s\n' "$T" | grep -c '(0 rows)' ; true)" != "2" ]; then
    echo "=== $d" >> "$OUT"
    printf '%s\n' "$T" >> "$OUT"
    hit=$((hit+1))
  fi
done
echo "-- rows=$rows SKIP=$skip WITH-CANDIDATES=$hit" | tee -a "$OUT"
