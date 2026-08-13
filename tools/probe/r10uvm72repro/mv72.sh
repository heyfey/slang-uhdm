#!/usr/bin/env bash
# r10uvm72 -- PER-SHAPE CONTENT ANALYSIS OF EVERY MOVER, by MULTISET.
#
#   usage: mv72.sh <patched_wd> <pristine_wd> <outdir> [rel/path/slang.uhdm ...]
#          (with no paths, every mover found by byteverify's rule is analysed)
#
# WHY MULTISET AND NOT `diff`.  A positional `diff` of two uhdm dumps reports
# RE-INDENTATION as change: remove a subtree and everything that used to print
# under it prints at a different column, so a 30-line deletion reads as
# "210 removed / 180 added".  Sorting whitespace-stripped lines and diffing the
# MULTISETS reports the CONTENT delta and nothing else -- and it is the
# instrument the standing rules name as the authority, because the size delta
# can be ZERO for a real change and NONZERO for pure noise.
#
# The 0-added / N-removed reading is the one that proves a PURE DELETION.
#
# TRAPS: uhdm-dump's FIRST LINE is the database path and always differs between
# two workdirs -> `sed 1d` on both; a missing database is FATAL, never skipped.
set -u
A=${1:?patched workdir}
B=${2:?pristine workdir}
OUT=${3:?outdir}
shift 3
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump at $DUMP"; exit 3; }
mkdir -p "$OUT" || exit 1

if [ "$#" -gt 0 ]; then
  PATHS="$*"
else
  PATHS=$( (cd "$A" && find . -name slang.uhdm | sort) | while read -r p; do
             cmp -s "$A/$p" "$B/$p" || echo "$p"; done )
fi

n=0
for p in $PATHS; do
  [ -f "$A/$p" ] && [ -f "$B/$p" ] || { echo "FATAL: missing $p"; exit 4; }
  tag=$(echo "$p" | tr '/' '_')
  "$DUMP" "$B/$p" 2>/dev/null | sed 1d | sed 's/^ *//' | sort > "$OUT/$tag.pris"
  "$DUMP" "$A/$p" 2>/dev/null | sed 1d | sed 's/^ *//' | sort > "$OUT/$tag.fin"
  diff "$OUT/$tag.pris" "$OUT/$tag.fin" > "$OUT/$tag.mdiff"
  rm=$(grep -c '^<' "$OUT/$tag.mdiff" || true)
  ad=$(grep -c '^>' "$OUT/$tag.mdiff" || true)
  sa=$(stat -c%s "$A/$p"); sb=$(stat -c%s "$B/$p")
  printf '%-46s REMOVED=%-5s ADDED=%-5s  size %s -> %s (delta %s)\n' \
     "$p" "$rm" "$ad" "$sb" "$sa" "$((sa - sb))"
  echo "   removed shapes:"
  grep '^<' "$OUT/$tag.mdiff" | sed 's/(.*)//' | sort | uniq -c | sort -rn \
      | sed 's/^/     /'
  if [ "$ad" -gt 0 ]; then
    echo "   ADDED shapes (a pure deletion must have NONE):"
    grep '^>' "$OUT/$tag.mdiff" | sed 's/(.*)//' | sort | uniq -c | sort -rn \
        | sed 's/^/     /'
  fi
  n=$((n + 1))
done
echo "-- movers analysed: $n"
