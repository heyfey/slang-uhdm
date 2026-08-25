#!/usr/bin/env bash
# r10uvm130repro/fence130.sh — THE FENCE, written from PRISTINE databases only.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   fence130.sh <sweep workdir> <cen bin> <out.tsv>
#
# For every test in a sweep workdir it censuses BOTH sides with ct130cen and
# joins the REFERENCE rows on the key both producers can spell — (view, owner
# fullname, reference span, reference name).  A reference in a DYNAMIC-ARRAY
# `new[...]` argument list has a DEAD vpiParent chain on BOTH sides (that is the
# whole law), so its view/owner columns read OTHER/- in both databases and the
# span+name half of the key carries it; the join is therefore ANY-semantics —
# "does ANY copy of this reference bind an implicit wire".
#
#   HIT     golden binds an IMPLICIT MODULE WIRE, we bind NOTHING anywhere, and
#           OUR OWN database says the reference sits in a dynamic-array
#           `new[...]` argument list (CTX=NEWARG) with a parent that is NOT a
#           hier_path.  These are the sites § 130 must move — nothing else may.
#   OTHER   golden binds an implicit wire and we do not, but the shape is NOT
#           the family's.  These must NOT move; they are other laws' residues.
#   MIRROR  WE bind an implicit wire where golden binds none, in the family's
#           shape — a WIDENING.  Must stay 0.
set -u
W=$1; CEN=$2; OUT=$3
: > "$OUT"
TMPD=$(mktemp -d /tmp/r10uvm130_fence.XXXXXX)
trap 'rm -rf "$TMPD"' EXIT
tests=0; skip=0
while IFS= read -r d; do
  c="$d/cmds.txt"; o="$d/slang.uhdm"
  [ -f "$c" ] && [ -f "$o" ] || { skip=$((skip+1)); continue; }
  g=$(grep -o '/[^ )]*golden\.uhdm' "$c" | head -1)
  if [ -z "$g" ]; then
    gc=$(grep -o '/[^ )]*slang-uhdm-goldens/[0-9a-f]*' "$c" | head -1)
    [ -n "$gc" ] && g="$gc/golden.uhdm"
  fi
  [ -n "$g" ] && [ -f "$g" ] || { skip=$((skip+1)); continue; }
  name=$(basename "$d"); mode=$(basename "$(dirname "$d")")
  tests=$((tests+1))
  "$CEN" "$g" G > "$TMPD/f130.g" 2>/dev/null
  "$CEN" "$o" O > "$TMPD/f130.o" 2>/dev/null
  awk -F'\t' -v M="$mode" -v N="$name" '
    # --- pass 1: OUR side.
    FNR==NR {
      if ($2=="REF") {
        k=$3"|"$6"|"$7"|"$8
        if ($9!="NONE") obound[k]=1; else if (!(k in obound)) obound[k]=0
        if ($13=="IMPL") oimpl[k]=1
        if ($15=="NEWARG" && $11!="hier_path") ofam[k]=1
        oseen[k]=1
      }
      next
    }
    # --- pass 2: GOLDEN.
    $2!="REF" { next }
    {
      k=$3"|"$6"|"$7"|"$8
      if ($13=="IMPL") gimpl[k]=1
      if ($9!="NONE") gbound[k]=1
      gseen[k]=1
    }
    END {
      for (k in gseen) {
        if ((k in gimpl) && (k in oseen) && !obound[k]) {
          split(k,a,"|")
          print ((k in ofam) ? "HIT" : "OTHER")"\t"M"\t"N"\t"a[1]"\t"a[2]"\t"a[3]"\t"a[4]
        }
      }
      for (k in oimpl) {
        if ((k in gseen) && !(k in gimpl) && !(k in gbound)) {
          split(k,a,"|")
          print "MIRROR\t"M"\t"N"\t"a[1]"\t"a[2]"\t"a[3]"\t"a[4]
        }
      }
    }' "$TMPD/f130.o" "$TMPD/f130.g" >> "$OUT"
done < <(find "$W" -mindepth 2 -maxdepth 2 -type d | sort)
h=$(grep -c '^HIT' "$OUT"); o2=$(grep -c '^OTHER' "$OUT"); m=$(grep -c '^MIRROR' "$OUT")
echo "MEASURED=$tests SKIP=$skip HIT=$h OTHER=$o2 MIRROR=$m"
echo "databases that MUST move:"
grep '^HIT' "$OUT" | cut -f2,3 | sort -u
