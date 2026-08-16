#!/usr/bin/env bash
# r10uvm78repro/mv78.sh — PER-SHAPE MULTISET content analysis of every mover.
#
#   usage: mv78.sh <patched_wd> <pristine_wd> <relpath> [<relpath> ...]
#
# THE MOVER RULE, encoded: a NONZERO size delta proves a mover REAL; a ZERO
# delta PROVES NOTHING, so the authority is the per-shape content analysis
# below — ADDED and REMOVED counted as SEPARATE multisets, never as a net.
#
# Object ids are stripped (`, id:N`) because the serializer renumbers on any
# structural change and an id churn would drown the real delta.  The dump's
# first line embeds the workdir path, so it is dropped (`sed 1d`) — a
# cross-workdir diff otherwise prints path noise as content.
set -u
# comm compares under the AMBIENT locale; the files are sorted under C.  Pin
# the whole script to C so the two can never disagree (a locale mismatch makes
# comm print "file is not in sorted order" and then emit rows that are in BOTH
# sides — a silently WRONG multiset).
export LC_ALL=C
A=${1:?patched wd}
B=${2:?pristine wd}
shift 2
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
OUT=${MV78OUT:-/tmp/r10uvm78_mv}
mkdir -p "$OUT" || exit 9
for p in "$@"; do
  t=$(echo "$p" | tr '/.' '__')
  for side in pat pris; do
    root=$A; [ $side = pris ] && root=$B
    f="$root/$p"
    if [ ! -f "$f" ]; then echo "NOFILE $side $p"; continue; fi
    "$DUMP" "$f" 2>/dev/null | sed 1d | sed -E 's/, id:[0-9]+//g' |
      sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' | LC_ALL=C sort > "$OUT/$t.$side"
  done
  [ -f "$OUT/$t.pat" ] && [ -f "$OUT/$t.pris" ] || continue
  sa=$(stat -c%s "$A/$p"); sb=$(stat -c%s "$B/$p")
  # uniq -c prefixes a RIGHT-ALIGNED count, which is NOT in the collation
  # order comm needs; re-sorting after the count is what makes comm's
  # "file is not in sorted order" warning (and the bogus rows it then prints)
  # go away.  Counted shapes, so a shape whose MULTIPLICITY changed shows up.
  cnt() { uniq -c "$1" | sed -E 's/^ +//' | LC_ALL=C sort; }
  cnt "$OUT/$t.pris" > "$OUT/$t.cpris"
  cnt "$OUT/$t.pat"  > "$OUT/$t.cpat"
  rem=$(comm -23 "$OUT/$t.cpris" "$OUT/$t.cpat" | wc -l)
  add=$(comm -13 "$OUT/$t.cpris" "$OUT/$t.cpat" | wc -l)
  echo "== $p  sizedelta=$((sa-sb))  REMOVED_shapes=$rem  ADDED_shapes=$add"
  comm -23 "$OUT/$t.cpris" "$OUT/$t.cpat" | sed 's/^/  - /'
  comm -13 "$OUT/$t.cpris" "$OUT/$t.cpat" | sed 's/^/  + /'
done
