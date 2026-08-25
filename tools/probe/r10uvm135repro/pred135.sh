#!/usr/bin/env bash
# r10uvm135repro/pred135.sh — THE MOVER PREDICTOR, reading OUR SIDE ALONE.
# MEASUREMENT ONLY.  No golden database is opened.
#
#   pred135.sh <sweep workdir> <ct135cen binary> <out.tsv>
#
# A `MAY-MOVE` row is an associative-index-NAME cell (an AIDX row) written in a
# body whose HOME can hoist: an OUT-OF-BODY class method or a PACKAGE-owned free
# subroutine (`OOB`/`PKG` in the census's own columns), in the ELABORATED
# package listing.  It is a SUPERSET of the fence's HIT set: a database whose
# modules import no such package hoists nothing, and a bracket name that IS a
# `typedef` is resolved by Surelog's `getObject` and never reaches the pool
# (assocIdxNameHoistable135) — neither of which this side-blind view can see.
# `OUTER` counts every other AIDX row (class properties, in-body methods,
# module-scope declarations, the def listings).
set -u
WD=${1:?sweep workdir}; CEN=${2:?ct135cen}; OUT=${3:?out.tsv}
: > "$OUT"
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    t=$(basename "$d"); O="$d/slang.uhdm"
    [ -f "$O" ] || continue
    "$CEN" "$O" O 2>/dev/null | awk -F'\t' -v mode="$mode" -v t="$t" '
      $2=="AIDX" {
        cls = ($3=="ELABPKG" && ($5=="OOB" || $6=="PKG")) ? "MAY-MOVE" : "OUTER"
        print cls "\t" mode "\t" t "\t" $4 "\t" $7 "\t" $8 "\t" $9
      }' >> "$OUT"
  done
done
echo "MAY-MOVE $(grep -c '^MAY-MOVE	' "$OUT"; true)  in databases $(awk -F'\t' '$1=="MAY-MOVE"{print $2"/"$3}' "$OUT" | sort -u | wc -l)"
echo "OUTER    $(grep -c '^OUTER	' "$OUT"; true)"
awk -F'\t' '$1=="MAY-MOVE"{print $7}' "$OUT" | sort | uniq -c | sort -rn | head -20
