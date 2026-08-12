#!/usr/bin/env bash
# r10earl31 — PER-SHAPE MOVER ATTRIBUTION AGAINST GOLDEN.
#
#   usage: mv31.sh <golden.dump> <pristine.dump> <patched.dump> [label]
#          SELFCHECK=1 mv31.sh ...      (fabricated-shape control)
#
# All three inputs must already have uhdm-dump's FIRST LINE (the database path)
# stripped, and the pristine/patched pair must come from runs whose WORKDIR PATHS
# are identical, or the file-path text inside the dump becomes a fake mover (this
# pass measured 74 fake "diff sides" on its own over-fire control that way).
#
# WHY NOT `diff -u | grep -c '^[-+]'`: that is an LCS measure and a re-alignment
# can move it by thousands with no content change.  This instrument takes the
# MULTISET DELTA of dump lines (indentation stripped, because an object is not a
# dump occurrence) and looks EVERY distinct changed shape up in GOLDEN with a
# per-shape `grep -Fxc`.  ADDED and REMOVED are reported SEPARATELY:
#   ADDED   shape with golden-count 0            -> OVER-FIRE
#   REMOVED shape with golden-count > 0 remaining-> UNDER-FIRE
# and the exact golden/before/after triple is printed for every shape, so no
# aggregate ever stands in for an attribution.
#
# CAVEAT INHERITED FROM r10uvm58 §5.2 AND RESTATED: NEVER ATTRIBUTE A BARE FIELD
# LINE.  Once indentation is stripped, a line like `|vpiConstType:7` has no
# owner, so its multiplicity is a whole-database aggregate.  This pass's law
# changes EXACTLY such lines, so the bare-line counts are reported as an
# aggregate and the real attribution is done SPAN-KEYED by census31.py instead —
# see README §5 (and cells31.py for the per-cell join).  A shape line that carries an object header IS attributable.
set -u
G=${1:?golden dump}
P=${2:?pristine dump}
Q=${3:?patched dump}
L=${4:-mover}
for f in "$G" "$P" "$Q"; do
  [ -s "$f" ] || { echo "NO_INPUT: missing or empty $f"; exit 6; }
done
T=$(mktemp -d)
strip() { sed -E 's/^ +//' "$1" | sort > "$2"; }
strip "$P" "$T/p"; strip "$Q" "$T/q"; strip "$G" "$T/g"
# multiset delta, both directions
comm -13 "$T/p" "$T/q" | sort | uniq -c | sed -E 's/^ *([0-9]+) /\1\t/' > "$T/add"
comm -23 "$T/p" "$T/q" | sort | uniq -c | sed -E 's/^ *([0-9]+) /\1\t/' > "$T/rem"
if [ "${SELFCHECK:-0}" = 1 ]; then
  printf '1\t\\_FABRICATED_SHAPE_r10earl31: (never in golden)\n' >> "$T/add"
  printf '1\t\\_FABRICATED_REMOVED_r10earl31: (never in golden)\n' >> "$T/rem"
fi
ai=$(awk -F'\t' '{s+=$1} END{print s+0}' "$T/add")
ri=$(awk -F'\t' '{s+=$1} END{print s+0}' "$T/rem")
echo "== $L: ADDED instances=$ai over $(wc -l < "$T/add") distinct shapes;" \
     "REMOVED instances=$ri over $(wc -l < "$T/rem") distinct shapes"
over=0; okA=0
while IFS=$'\t' read -r n sh; do
  gc=$(grep -Fxc -- "$sh" "$T/g" || true)
  if [ "$gc" = 0 ]; then
    echo "  ADDED   x$n golden=0 OVER-FIRE   $sh"; over=$((over+1))
  else
    okA=$((okA+1))
    [ "${VERBOSE:-0}" = 1 ] && echo "  ADDED   x$n golden=$gc ok   $sh"
  fi
done < "$T/add"
under=0; okR=0
while IFS=$'\t' read -r n sh; do
  gc=$(grep -Fxc -- "$sh" "$T/g" || true)
  qc=$(grep -Fxc -- "$sh" "$T/q" || true)
  if [ "$gc" -gt "$qc" ]; then
    echo "  REMOVED x$n golden=$gc ours_after=$qc UNDER-FIRE $sh"; under=$((under+1))
  else
    okR=$((okR+1))
    [ "${VERBOSE:-0}" = 1 ] && echo "  REMOVED x$n golden=$gc ours_after=$qc ok   $sh"
  fi
done < "$T/rem"
echo "  ADDED  : $okA covered, $over OVER-FIRE"
echo "  REMOVED: $okR correct, $under UNDER-FIRE"
rm -rf "$T"
