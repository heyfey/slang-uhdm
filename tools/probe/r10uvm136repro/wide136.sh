#!/usr/bin/env bash
# r10uvm136 — THE WIDE CLASS-PROPERTY KIND CENSUS.  For every database in a
# verify_golden workdir: cen136 the row's OWN golden (path read out of that
# row's cmds.txt, never guessed; the cache DIRECTORY is turned into
# .../golden.uhdm) and cen136 ours, MULTISET-join the cells on
# (SITE, IDX, property name) and print every cell whose VARIABLE CLASS differs.
#
#   usage: CEN136=.. wide136.sh <workdir> <out.tsv>
# out.tsv rows:  <mode>/<test> \t <site> \t <idx> \t <name> \t <goldenkind> \t <ourkind> \t <goldenTS> \t <ourTS>
# LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY — the judge is uhdm-cmp.
set -u
WD=${1:?workdir}; OUT=${2:?out}
CEN=${CEN136:?set CEN136}
: > "$OUT"
n=0; ng=0
find "$WD" -name slang.uhdm | sort > "$OUT.list"
while read -r f <&3; do
  d=$(dirname "$f"); rel=${d#$WD/}
  g=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
  [ -n "$g" ] && [ -f "$g/golden.uhdm" ] || { n=$((n+1)); continue; }
  ng=$((ng+1))
  "$CEN" "$g/golden.uhdm" 2>/dev/null | awk -F'\t' '{split($4,v,"|"); print $2"\x01"$3"\x01"v[2]"\t"v[1]"\t"$5}' | sort > "$OUT.g"
  "$CEN" "$f"             2>/dev/null | awk -F'\t' '{split($4,v,"|"); print $2"\x01"$3"\x01"v[2]"\t"v[1]"\t"$5}' | sort > "$OUT.o"
  join -t$'\t' -j1 "$OUT.g" "$OUT.o" -o 1.1,1.2,2.2,1.3,2.3 |
    awk -F'\t' -v R="$rel" '$2!=$3 {gsub(/\x01/,"\t",$1); print R "\t" $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5}' >> "$OUT"
  n=$((n+1))
done 3< "$OUT.list"
rm -f "$OUT.g" "$OUT.o"
echo "DBS_SCANNED=$n  DBS_WITH_GOLDEN=$ng"
echo "KIND_DISAGREEING_CELLS=$(wc -l < "$OUT")"
awk -F'\t' '{print $5" -> "$6}' "$OUT" | sort | uniq -c | sort -rn | sed 's/^/  PAIR /'
