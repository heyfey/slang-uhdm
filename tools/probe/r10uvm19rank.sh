#!/bin/bash
# r10uvm19rank.sh [N] [ourdir] [mode] — rank the UVM-4 body residue.
# mode = part (default, part+kind pair) | whycls (first-differing property)
set -u
N=${1:-25}; O=${2:-/tmp/r10uvm19_m}; M=${3:-part}
W=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TMP=$(mktemp)
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  bash "$W/r10uvm19p.sh" $T "$O" $M >> "$TMP"
done
awk -F'  *' '{n=$1; $1=""; sub(/^ +/,""); c[$0]+=n} END{for (k in c) printf "%8d  %s\n", c[k], k}' \
  "$TMP" | sort -rn | head -$N
rm -f "$TMP"
