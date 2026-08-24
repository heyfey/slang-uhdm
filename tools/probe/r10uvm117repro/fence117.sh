#!/usr/bin/env bash
# r10uvm117repro/fence117.sh — THE FENCE, written from PRISTINE databases only.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   fence117.sh <sweep workdir> <cen bin> <out.tsv>
#
# For every test in a sweep workdir it censuses BOTH sides with ct117cen and
# joins the REFERENCE rows on the key both producers can spell — (view, owner
# fullname, reference span, reference name) — reporting:
#
#   HIT     golden binds an IMPLICIT MODULE WIRE, we bind NOTHING, the owning
#           subroutine is a FREE PACKAGE SUBROUTINE (HOME=PKG and the owner's
#           own VpiName carries no "::"), and the name IS a `ref_var` local of
#           that owner in OUR OWN database.  These are the sites § 117 must
#           move — and nothing else may move.
#   OTHER   golden binds an implicit wire, we bind nothing, but the shape is
#           NOT the family's (an out-of-body class method, a module function,
#           a name that is not a `ref_var` local on our side).  These must NOT
#           move; they are other laws' residues.
#   MIRROR  WE bind an implicit wire where golden binds nothing, in the
#           family's shape — a WIDENING.  Must stay 0.
set -u
W=$1; CEN=$2; OUT=$3
: > "$OUT"
TMPD=$(mktemp -d /tmp/r10uvm117_fence.XXXXXX)
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
  "$CEN" "$g" G > "$TMPD/f117.g" 2>/dev/null
  "$CEN" "$o" O > "$TMPD/f117.o" 2>/dev/null
  awk -F'\t' -v M="$mode" -v N="$name" '
    # --- pass 1: OUR side.  our reference bindings + our ref_var local set.
    FNR==NR {
      if ($2=="REF") { ok[$3"|"$6"|"$7"|"$8]=$9; oimpl[$3"|"$6"|"$7"|"$8]=$13 }
      else if ($2=="RV") { orv[$3"|"$6"|"$7]=1 }
      next
    }
    # --- pass 2: GOLDEN.
    $2=="RV" { grv[$3"|"$6"|"$7]=1; next }
    $2!="REF" { next }
    {
      k=$3"|"$6"|"$7"|"$8; nk=$3"|"$6"|"$8
      # the family shape, read off GOLDEN alone except for the ref_var test,
      # which is read off OUR side (that is the object our predicate keys on).
      fam = ($5=="PKG" && $4=="IB" && (nk in orv))
      if ($13=="IMPL" && (k in ok) && ok[k]=="NONE")
        print (fam ? "HIT" : "OTHER")"\t"M"\t"N"\t"$3"\t"$5"\t"$4"\t"$6"\t"$7"\t"$8
      else if ($13!="IMPL" && $9=="NONE" && (k in oimpl) && oimpl[k]=="IMPL")
        print "MIRROR\t"M"\t"N"\t"$3"\t"$5"\t"$4"\t"$6"\t"$7"\t"$8
    }' "$TMPD/f117.o" "$TMPD/f117.g" >> "$OUT"
done < <(find "$W" -mindepth 2 -maxdepth 2 -type d | sort)
h=$(grep -c '^HIT' "$OUT"); o2=$(grep -c '^OTHER' "$OUT"); m=$(grep -c '^MIRROR' "$OUT")
echo "MEASURED=$tests SKIP=$skip HIT=$h OTHER=$o2 MIRROR=$m"
echo "databases that MUST move:"
grep '^HIT' "$OUT" | cut -f2,3 | sort -u
