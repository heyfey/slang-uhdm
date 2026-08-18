#!/usr/bin/env bash
# r10uvm95 MOVER ATTRIBUTION — order-blind and id-blind.
#   ./attr95.sh <pat wd root> <pris wd root> <relative cell path>
# Dumps both databases, strips object ids and the embedded workdir path, sorts,
# and reports the changed lines.  Scoreboard/default is a ~50/50 COIN, so only
# the ORDER-BLIND reading is attributable there.
set -u
A=${1:?pat}; B=${2:?pris}; P=${3:?cell}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
T=$(mktemp -d)
for tag in pat pris; do
  r=$A; [ $tag = pris ] && r=$B
  "$DUMP" "$r/$P/slang.uhdm" 2>/dev/null | sed 1d \
    | sed -E 's/, id:[0-9]+//g; s#/tmp/[A-Za-z0-9_]*/(sl|u2r)/[^ ,]*##g' > "$T/$tag.raw"
  sort "$T/$tag.raw" > "$T/$tag.srt"
done
echo "$P  raw:  ins=$(diff "$T/pris.raw" "$T/pat.raw" | grep -c '^>' ; true) del=$(diff "$T/pris.raw" "$T/pat.raw" | grep -c '^<' ; true)"
echo "$P  sort: ins=$(diff "$T/pris.srt" "$T/pat.srt" | grep -c '^>' ; true) del=$(diff "$T/pris.srt" "$T/pat.srt" | grep -c '^<' ; true)"
echo "--- line KINDS changed (order-blind) ---"
diff "$T/pris.srt" "$T/pat.srt" | grep -E '^[<>]' | sed -E 's/^([<>]) *//; s/^\\_([a-z_]+):.*/OBJ \1/; s/^\|([A-Za-z]+).*/ATTR \1/' | sort | uniq -c | sort -rn | head -20
echo "--- sample ---"
diff "$T/pris.srt" "$T/pat.srt" | grep -E '^[<>]' | head -12
rm -rf "$T"
