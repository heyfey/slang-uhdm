#!/usr/bin/env bash
# r10buvm7 — PER-MOVER ATTRIBUTION.  For each moved database, prove that every
# moved DUMP LINE belongs to a statement the law names.
#
#   usage: attrib7.sh <patched-workdir> <pristine-workdir> <outdir> <relpath> [...]
#          (relpath as byteverify.sh prints it: ./<mode>/<test>-<hash>/slang.uhdm)
#
# Per mover:
#   DIFFLINES  raw `<`/`>` line count between the two dumps.
#   FLIPS      inc/dec operand SOURCE LINES that went PATH -> WIDEREF, read off
#              the census on the two databases (not guessed from the source).
#   RESIDUE    DIFFLINES after striplines7.py removed, from BOTH sides, every
#              object block anchored at a FLIPPED line.  RESIDUE must be 0: it
#              is the part of the move the law does not account for.
# Compared as SORTED LINE MULTISETS, so a pure permutation reads as 0 — and any
# permutation is reported separately, because a reordered database is a change
# even when it is not a content change.
set -u
A=${1:?patched workdir}
B=${2:?pristine workdir}
OUT=${3:?outdir}
shift 3
HERE=$(cd "$(dirname "$0")" && pwd)
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CEN=${R10BUVM7CEN:-/tmp/r10buvm7cen}
mkdir -p "$OUT" || exit 9
bad=0; n=0
printf "%-46s %10s %6s %8s %s\n" MOVER DIFFLINES FLIPS RESIDUE NOTE
for p in "$@"; do
  n=$((n+1))
  tag=$(echo "$p" | sed 's#^\./##; s#/slang.uhdm$##; s#/#_#g')
  d=$OUT/$tag; mkdir -p "$d" || exit 9
  [ -f "$A/$p" ] && [ -f "$B/$p" ] || { printf "%-46s %10s %6s %8s %s\n" "$tag" - - - MISSING; bad=$((bad+1)); continue; }
  "$DUMP" "$A/$p" 2>/dev/null | sed 1d > "$d/pat.dump"
  "$DUMP" "$B/$p" 2>/dev/null | sed 1d > "$d/pris.dump"
  dl=$(diff "$d/pris.dump" "$d/pat.dump" | grep -cE '^[<>]' || true)
  "$CEN" "$B/$p" PRIS > "$d/pris.cen"
  "$CEN" "$A/$p" PAT  > "$d/pat.cen"
  awk '/^INCDEC/ && $5=="PATH"{split($3,a,":"); print a[1]}' "$d/pris.cen" | sort -u > "$d/pris.path"
  awk '/^INCDEC/ && $5=="WIDEREF"{split($3,a,":"); print a[1]}' "$d/pat.cen" | sort -u > "$d/pat.wide"
  comm -12 "$d/pris.path" "$d/pat.wide" > "$d/flip.lines"
  fl=$(wc -l < "$d/flip.lines")
  if [ "$fl" -gt 0 ]; then
    python3 "$HERE/striplines7.py" "$d/pris.dump" $(cat "$d/flip.lines") > "$d/pris.strip" 2>"$d/pris.strip.log"
    python3 "$HERE/striplines7.py" "$d/pat.dump"  $(cat "$d/flip.lines") > "$d/pat.strip"  2>"$d/pat.strip.log"
  else
    cp "$d/pris.dump" "$d/pris.strip"; cp "$d/pat.dump" "$d/pat.strip"
  fi
  r=$(diff <(sort "$d/pris.strip") <(sort "$d/pat.strip") | grep -cE '^[<>]' || true)
  # ORDER check: same multiset, different order?
  perm=SAME_ORDER
  cmp -s "$d/pris.strip" "$d/pat.strip" || perm=PERMUTED
  note=OK
  [ "$r" -gt 0 ] && { note=RESIDUE; bad=$((bad+1)); }
  printf "%-46s %10s %6s %8s %s\n" "$tag" "$dl" "$fl" "$r" "$note/$perm"
  if [ "$r" -gt 0 ]; then
    diff <(sort "$d/pris.strip") <(sort "$d/pat.strip") | grep -E '^[<>]' | head -20 | sed 's/^/     /'
  fi
done
echo "-- movers=$n RESIDUE-MOVERS=$bad"
[ "$bad" -eq 0 ] && echo "PASS: every moved line belongs to a statement the law names" \
                 || { echo "FAIL: unattributed movement"; exit 1; }
