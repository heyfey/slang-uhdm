#!/usr/bin/env bash
# cells.sh <arm outdir> <type-regex> [name-regex]: per-CELL field score of one
# arm (outdir from arm.sh): every object of the kind in the downstream-lane
# golden (gds.uhdm) and in ours (ours_ds.uhdm) as a row
#   type name span [val=VpiValue] <- parent-type(parent-name)
# (idlist, id/rank columns dropped), joined as a MULTISET.  Prints
#   CELLS <arm> golden=<n> matched=<m> ours=<k>  and the unmatched rows.
set -u
O=$1; T=$2; N=${3:-.*}
IDL=${IDL:-/tmp/r11u120_idlist}
f() { $IDL "$1" "$T" "$N" | cut -d' ' -f4- | sed 's/@[0-9]*\.[0-9]*$//' | sort; }
f "$O/gds.uhdm" > "$O/cells_g.txt"; f "$O/ours_ds.uhdm" > "$O/cells_o.txt"
g=$(wc -l < "$O/cells_g.txt"); k=$(wc -l < "$O/cells_o.txt")
m=$(comm -12 "$O/cells_g.txt" "$O/cells_o.txt" | wc -l)
echo "CELLS $(basename $O) golden=$g matched=$m ours=$k"
comm -3 "$O/cells_g.txt" "$O/cells_o.txt" | sed 's/^\t/  OURS  /; t; s/^/  GOLD  /'
