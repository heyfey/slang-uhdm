#!/usr/bin/env bash
# r10uvm109repro/pred109.sh - THE MOVER PREDICTOR, from OUR SIDE ALONE.
# MEASUREMENT ONLY.  A database can move under law classPropNewLhsNoHoist109
# only if OUR PRISTINE database holds at least one `ref_obj` bound to an
# IMPLICIT MODULE WIRE whose own vpiParent is a `hier_path`.  Two bounds, both
# read from OUR SIDE ALONE, no golden:
#   OUTER    that wide shape alone (any implicit-wire-bound hier_path base)
#   MAY-MOVE the wide shape PLUS the exact `p = new(...)` lvalue signature
#            NEWLHS -- the law's own population.
#
#   pred109.sh <sweep workdir> <cen bin> <out.tsv>
set -u
W=$1; CEN=$2; OUT=$3
: > "$OUT"
n=0; may=0
while IFS= read -r d; do
  o="$d/slang.uhdm"; [ -f "$o" ] || continue
  name=$(basename "$d"); mode=$(basename "$(dirname "$d")")
  n=$((n+1))
  read -r wide exact < <("$CEN" "$o" O 2>/dev/null | awk -F'\t' '
      $2=="REF" && $12=="IMPL" && $10=="hier_path" { w++ }
      $2=="REF" && $12=="IMPL" && $13=="NEWLHS"    { e++ }
      END { print (w+0), (e+0) }')
  if [ "$wide" -gt 0 ]; then
    may=$((may+1))
    tagp=OUTER; [ "$exact" -gt 0 ] && tagp=MAY-MOVE
    printf '%s\t%s\t%s\twide=%s\texact=%s\n' "$tagp" "$mode" "$name" "$wide" "$exact" >> "$OUT"
  fi
done < <(find "$W" -mindepth 2 -maxdepth 2 -type d | sort)
echo "MEASURED=$n WITH-WIDE-SHAPE=$may MAY-MOVE=$(grep -c '^MAY-MOVE' "$OUT" || true)"
cat "$OUT"
