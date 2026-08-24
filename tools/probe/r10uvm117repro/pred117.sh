#!/usr/bin/env bash
# r10uvm117repro/pred117.sh — THE MOVER PREDICTOR, written from PRISTINE
# databases and from OUR SIDE ALONE (no golden is opened).  MEASUREMENT ONLY.
#
#   pred117.sh <sweep workdir> <cen bin> <out.tsv>
#
# A database can only move if it holds a reference that
#   * lives in the ELABORATED package listing (ELABPKG) — the only view the law
#     touches; the def copy stays unbound by construction,
#   * is owned by a FREE PACKAGE SUBROUTINE (HOME=PKG and the owner's own name
#     carries no "::"),
#   * names a `ref_var` LOCAL of that same owner in OUR OWN database,
#   * carries NO actual today (ACT=NONE) — a reference our § refVarLocalWindow-
#     Binds5 already binds keeps its binding, and
#   * is not a hier_path element or a method-call RECEIVER — the two builders
#     that keep a name out of Surelog's pool (§ classPropNewLhsNoHoist109).
# OUTER drops the last test; MAY-MOVE is the exact shape.
set -u
W=$1; CEN=$2; OUT=$3
: > "$OUT"
TMPD=$(mktemp -d /tmp/r10uvm117_pred.XXXXXX)
trap 'rm -rf "$TMPD"' EXIT
tests=0; skip=0
while IFS= read -r d; do
  o="$d/slang.uhdm"
  [ -f "$o" ] || { skip=$((skip+1)); continue; }
  name=$(basename "$d"); mode=$(basename "$(dirname "$d")")
  tests=$((tests+1))
  "$CEN" "$o" O > "$TMPD/p117.o" 2>/dev/null
  awk -F'\t' -v M="$mode" -v N="$name" '
    $2=="RV" { rv[$3"|"$6"|"$7]=1; next }
    $2!="REF" { next }
    $3=="ELABPKG" && $5=="PKG" && $4=="IB" && $9=="NONE" &&
    (($3"|"$6"|"$8) in rv) {
      inner = ($11=="hier_path" || $11=="method_func_call") ? "OUTER" : "MAY-MOVE"
      print inner"\t"M"\t"N"\t"$6"\t"$7"\t"$8"\t"$11
    }' "$TMPD/p117.o" >> "$OUT"
done < <(find "$W" -mindepth 2 -maxdepth 2 -type d | sort)
mm=$(grep -c '^MAY-MOVE' "$OUT"); ou=$(grep -c '^OUTER' "$OUT")
echo "MEASURED=$tests SKIP=$skip MAY-MOVE=$mm OUTER=$ou"
echo "databases with the exact shape:"
grep '^MAY-MOVE' "$OUT" | cut -f2,3 | sort -u
echo "databases with the outer shape only:"
comm -23 <(grep '^OUTER' "$OUT" | cut -f2,3 | sort -u) <(grep '^MAY-MOVE' "$OUT" | cut -f2,3 | sort -u)
