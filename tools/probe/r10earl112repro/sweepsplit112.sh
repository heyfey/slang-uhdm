#!/bin/bash
# r10earl112 -- turn TWO censweep112 `rows.tsv` files (one taken with the
# PRISTINE binary, one with the PATCHED binary) into the three files cen112.py
# scores, keyed by ROW|CENSUS-KEY so cells from different databases can never
# collide.
#
# MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
#
#   usage: sweepsplit112.sh <pris-rows.tsv> <patch-rows.tsv> <outdir>
#
# GUARD: the GOLDEN half of the two sweeps must be IDENTICAL (the same cache
# entries, read twice).  If it is not, the two sweeps did not see the same
# goldens and NOTHING below is comparable -- so it is asserted, not assumed.
set -u
P=${1:?pristine rows.tsv}; A=${2:?patched rows.tsv}; O=${3:?outdir}
mkdir -p "$O" || exit 1
awk -F'\t' '$1=="G"{print $2"|"$3"\t"$4"\t"$5}' "$P" | sort > "$O/gold.pris.txt"
awk -F'\t' '$1=="G"{print $2"|"$3"\t"$4"\t"$5}' "$A" | sort > "$O/gold.patch.txt"
if ! cmp -s "$O/gold.pris.txt" "$O/gold.patch.txt"; then
  echo "FATAL: the two sweeps' GOLDEN halves differ -- not comparable"
  diff "$O/gold.pris.txt" "$O/gold.patch.txt" | head -20
  exit 3
fi
cp "$O/gold.pris.txt" "$O/gold.txt"; echo "CENRC 0" >> "$O/gold.txt"
awk -F'\t' '$1=="O"{print $2"|"$3"\t"$4"\t"$5}' "$P" | sort > "$O/pris.txt"
echo "CENRC 0" >> "$O/pris.txt"
awk -F'\t' '$1=="O"{print $2"|"$3"\t"$4"\t"$5}' "$A" | sort > "$O/patch.txt"
echo "CENRC 0" >> "$O/patch.txt"
for f in gold pris patch; do
  for fam in HPN HPR; do
    grep "|$fam|" "$O/$f.txt" > "$O/$f.$fam.txt"
    echo "CENRC 0" >> "$O/$f.$fam.txt"
  done
done
wc -l "$O"/gold.txt "$O"/pris.txt "$O"/patch.txt
echo "GOLDEN HALVES IDENTICAL"
