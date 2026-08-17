#!/usr/bin/env bash
# r10buvm12repro/cenall12.sh — THE CORPUS-WIDE CENSUS, golden vs ours, over
# every database of one verify_golden workdir.
#
#   usage: cenall12.sh <workdir root> <outfile> [name-filter-regex]
#
# For each test the GOLDEN path is read out of that test's OWN cmds.txt (never
# guessed), the census is run on both sides, and cenjoin12.py classifies every
# tf_call ID-blind and address-blind.  Per test it prints the four class
# counts and the DISAGREEING count; the tail sums them.
#
# GUARDS:
#   * uhdm-cmp and friends EXIT 0 ON A MISSING FILE, so both sides are
#     existence-checked and a missing side prints SKIP and is COUNTED.
#   * the golden cache entry is a DIRECTORY; it is turned into .../golden.uhdm.
#   * a run that reached nothing is FATAL — a green line from a gate that ran
#     nothing is the trap this campaign has paid for twice.
set -u
W=${1:?workdir root}
O=${2:?outfile}
FILT=${3:-.}
CEN=/tmp/r10buvm12cen
D=$(cd "$(dirname "$0")" && pwd)
[ -x "$CEN" ] || { echo "FATAL no census $CEN"; exit 3; }
: > "$O"
n=0; skip=0; dis=0
for c in "$W"/*/*/cmds.txt; do
  [ -f "$c" ] || continue
  d=$(dirname "$c")
  nm=$(basename "$d"); nm=${nm%-*}
  echo "$nm" | grep -qE "$FILT" || continue
  g=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$c" | head -1)
  [ -n "$g" ] && [ -d "$g" ] && g=$g/golden.uhdm
  o=$d/slang.uhdm
  if [ -z "$g" ] || [ ! -f "$g" ] || [ ! -f "$o" ]; then
    echo "SKIP $nm $(basename "$(dirname "$d")") (g=${g:-none})" >> "$O"; skip=$((skip+1)); continue
  fi
  tg=$(mktemp); to=$(mktemp)
  "$CEN" "$g" G > "$tg" 2>/dev/null; "$CEN" "$o" P > "$to" 2>/dev/null
  r=$("$D/cenjoin12.py" "$tg" G "$to" P 2>&1)
  # THE COUNT MUST BE A BARE INTEGER: cenjoin12 prints `DISAGREEING 39 (shown
  # 39)`, and the inherited one-field sed handed `39 (shown 39)` to $(( )),
  # whose SYNTAX ERROR aborted the whole loop and printed `tests=0 ... TOTAL
  # DISAGREEING=0` -- a ZERO from a gate that ran NOTHING.  Caught by the
  # script's own "reached NO tests" FATAL, which is why that guard is there.
  k=$(echo "$r" | sed -n 's/^DISAGREEING \([0-9]*\).*/\1/p')
  dis=$((dis + ${k:-0}))
  { echo "== $nm/$(basename "$(dirname "$d")")"; echo "$r" | sed 's/^/   /'; } >> "$O"
  n=$((n+1))
  rm -f "$tg" "$to"
done
echo "cenall12: tests=$n SKIP=$skip  TOTAL DISAGREEING=$dis  -> $O"
[ "$n" -gt 0 ] || { echo "FATAL: reached NO tests"; exit 5; }
grep -h '^  G=' "$O" | sed 's/^ *//' | sort | uniq -c | sort -rn | head -40
