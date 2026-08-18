#!/usr/bin/env bash
# r10buvm13repro/cenall13.sh — THE CORPUS-WIDE CENSUS, golden vs ours, over
# every database of one verify_golden workdir.
#
#   usage: cenall13.sh <workdir root> <outfile> [name-filter-regex]
#
# For each test the GOLDEN path is read out of that test's OWN cmds.txt (never
# guessed), the census is run on both sides, and cenjoin13.py classifies every
# formal-default-value ref cell ID-blind and address-blind, plus the io_decl
# LISTING per task_func.
#
# GUARDS:
#   * uhdm-cmp and friends EXIT 0 ON A MISSING FILE, so both sides are
#     existence-checked and a missing side prints SKIP and is COUNTED.
#   * the golden cache entry is a DIRECTORY; it is turned into .../golden.uhdm.
#   * a run that reached nothing is FATAL — a green line from a gate that ran
#     nothing is the trap this campaign has paid for twice.
#   * the number scraped out of cenjoin13 must be a BARE INTEGER (buvm12's
#     `39 (shown 39)` trap, whose $(( )) syntax error aborted the whole loop
#     and printed a green zero).
#   * the number of `== ` headers written is checked against the number of
#     `DV default-value refs (LOCATION-BLIND):` lines at the end, so a run that
#     lost joins midway (buvm12's moved-directory trap) cannot be reported.
set -u
W=${1:?workdir root}
O=${2:?outfile}
FILT=${3:-.}
CEN=/tmp/r10buvm13cen
D=$(cd "$(dirname "$0")" && pwd)
[ -x "$CEN" ] || { echo "FATAL no census $CEN"; exit 3; }
: > "$O"
n=0; skip=0
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
  r=$("$D/cenjoin13.py" "$tg" "$to" 6 2>&1)
  { echo "== $nm/$(basename "$(dirname "$d")")"; echo "$r" | sed 's/^/   /'; } >> "$O"
  n=$((n+1))
  rm -f "$tg" "$to"
done
hdr=$(grep -c '^== ' "$O" || true)
lb=$(grep -c 'LOCATION-BLIND):' "$O" || true)
echo "cenall13: tests=$n SKIP=$skip headers=$hdr locblind-lines=$lb -> $O"
[ "$n" -gt 0 ] || { echo "FATAL: reached NO tests"; exit 5; }
[ "$hdr" = "$lb" ] || { echo "FATAL: $hdr headers but $lb joins -- the run LOST joins"; exit 6; }
echo "-- IOV listing totals"
grep 'IOV listing:' "$O" | tr ' ' '\n' | grep '=' | awk -F= '{a[$1]+=$2} END{for(k in a) printf "   %s=%d\n", k, a[k]}'
echo "-- DV (LOCATION-BLIND) totals"
grep 'LOCATION-BLIND):' "$O" | sed 's/.*LOCATION-BLIND)://' | tr ' ' '\n' | grep '=' | awk -F= '{a[$1]+=$2} END{for(k in a) printf "   %s=%d\n", k, a[k]}'
echo "-- DV (location-keyed) totals"
grep 'location-keyed):' "$O" | sed 's/.*location-keyed)://' | tr ' ' '\n' | grep '=' | awk -F= '{a[$1]+=$2} END{for(k in a) printf "   %s=%d\n", k, a[k]}'
