#!/usr/bin/env bash
# r10uvm109repro/fence109.sh - THE FENCE, written from PRISTINE databases only.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#
#   fence109.sh <sweep workdir> <cen bin> <out.tsv>
#
# For every test in a sweep workdir it censuses BOTH sides and reports one row
# per reference that (a) is bound to an IMPLICIT MODULE WIRE on OUR side and
# (b) carries the `p = new(...)` lvalue signature NEWLHS -- the exact population
# law classPropNewLhsNoHoist109 unbinds.  The GOLDEN column is that database's
# answer for the same (view, owner, name) key.
#
#   HIT   ours implicit wire, golden binds NO implicit wire under that name in
#         that body -> the law's own cells; these MUST move.
#   RISK  ours implicit wire AND golden an implicit wire of the same name in the
#         same body -> a wire golden HAS; the law must never touch one.  A
#         nonzero RISK count blocks the pass.
# LHS is ALWAYS golden; RHS is ALWAYS ours.
set -u
W=$1; CEN=$2; OUT=$3
: > "$OUT"
TMPD=$(mktemp -d /tmp/r10uvm109_fence.XXXXXX)
trap 'rm -rf "$TMPD"' EXIT
tests=0; hit=0; risk=0; skip=0
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
  "$CEN" "$g" G > "$TMPD/f109.g" 2>/dev/null
  "$CEN" "$o" O > "$TMPD/f109.o" 2>/dev/null
  awk -F'\t' -v M="$mode" -v N="$name" '
    FNR==NR { if ($2=="REF" && $12=="IMPL") gkey[$3"|"$5"|"$7]=1; next }
    $2=="REF" && $12=="IMPL" && $13=="NEWLHS" {
      k=$3"|"$5"|"$7
      v = (k in gkey) ? "RISK" : "HIT"
      print v"\t"M"\t"N"\t"$3"\t"$5"\t"$6"\t"$7
    }' "$TMPD/f109.g" "$TMPD/f109.o" >> "$OUT"
done < <(find "$W" -mindepth 2 -maxdepth 2 -type d | sort)
hit=$(grep -c '^HIT' "$OUT" || true)
risk=$(grep -c '^RISK' "$OUT" || true)
echo "MEASURED=$tests SKIP=$skip HIT=$hit RISK=$risk"
echo "databases that MUST move:"
grep '^HIT' "$OUT" | cut -f2,3 | sort -u
