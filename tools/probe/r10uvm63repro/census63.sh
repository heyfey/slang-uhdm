#!/usr/bin/env bash
# r10uvm63 CORPUS CENSUS — predict the mover set BEFORE the patch is written.
#
#   usage: census63.sh <verify_golden-workdir> <outfile>
#
# WHAT IT COUNTS, and why it is a SUPERSET rather than an exact set.
# The patch can only add `|vpiSigned:1` to a typespec that (a) sits in an
# associative INDEX slot and (b) is one of the five SIGNED predefined-integer
# kinds.  Our OWN dump cannot distinguish `[int]` from `[int unsigned]` — both
# print as a bare `int_typespec`, and the missing flag is exactly what this pass
# adds — so the census counts every index-slot occurrence of the five kinds and
# reports it as a CANDIDATE.  The measured mover set must be a SUBSET of the
# candidates, and every candidate that did NOT move must be explainable as an
# `unsigned` spelling.  A mover OUTSIDE the candidate set would falsify the law.
#
# THE TWO INDEX SLOTS ARE COUNTED SEPARATELY because they are different code:
#   OUTER  `|vpiIndexTypespec:` -> ref_typespec -> vpiActual -> TS
#   INNER  a `STRING:associative` marker constant -> `|vpiTypespec:` -> ... -> TS
#
# GUARD (measure the measurer): a workdir with zero databases, or a database
# that dumps nothing, is reported as NO_DUMP and counted.  A census that read
# nothing must never print "0 candidates" and read as a prediction.
set -u
WD=${1:?workdir}
OUT=${2:?outfile}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump at $DUMP"; exit 3; }

# WINDOW SIZES ARE NOT GUESSES.  uhdm-dump prints the index edge as
#   |vpiIndexTypespec:      <- the edge
#   \_ref_typespec:         <- the ref object
#     |vpiParent: / \_array_typespec:
#     |vpiActual:           <- the edge to the typespec
#     \_<kind>_typespec:    <- THE OBJECT
# so the target is up to 5 lines below the edge and is ALWAYS the line right
# after `|vpiActual:`.  The scanner therefore keys on `|vpiActual:` inside a
# bounded window rather than on a fixed offset, and the window (10) is slack, not
# a measurement.  A window that was too short reported ZERO on an arm whose grid
# shows 21 index typespecs — that control is what this shape is a fix for, and
# it is re-run in README §2 on every arm before the corpus is scanned.
scan() {   # stdin = a dump; prints "<slot> <kind>" per index-slot occurrence
  awk '
    function kindof(s,   r) {
      if (s !~ /\\_(integer|int|byte|short_int|long_int)_typespec:/) return ""
      match(s, /\\_[a-z_]+_typespec:/)
      return substr(s, RSTART+2, RLENGTH-3)
    }
    /\|vpiIndexTypespec:/ { ow = 10; oa = 0; next }
    /STRING:associative/  { mw = 8; next }
    {
      if (ow > 0) {
        ow--
        if (oa) { k = kindof($0); if (k != "") print "OUTER " k; ow = 0; oa = 0 }
        else if ($0 ~ /\|vpiActual:/) oa = 1
      }
      if (iw > 0) {
        iw--
        if (ia) { k = kindof($0); if (k != "") print "INNER " k; iw = 0; ia = 0 }
        else if ($0 ~ /\|vpiActual:/) ia = 1
      }
      else if (mw > 0) {
        mw--
        if ($0 ~ /\|vpiTypespec:/) { iw = 10; ia = 0; mw = 0 }
      }
    }'
}

: > "$OUT"
n=0; nodump=0; cand=0
while IFS= read -r db; do
  n=$((n+1))
  rel=${db#"$WD"/}
  t=$("$DUMP" "$db" 2>/dev/null | sed '1d' | scan | sort | uniq -c |
      awk '{printf "%s*%s ", $1, $2"/"$3}')
  if [ -z "$t" ]; then
    # distinguish "dumped fine, no assoc index" from "dumped nothing"
    if ! "$DUMP" "$db" 2>/dev/null | sed '1d' | head -1 | grep -q .; then
      printf 'NO_DUMP\t%s\n' "$rel" >> "$OUT"; nodump=$((nodump+1))
    fi
    continue
  fi
  printf 'CAND\t%s\t%s\n' "$rel" "$t" >> "$OUT"
  cand=$((cand+1))
done < <(find "$WD" -name slang.uhdm -type f | sort)

echo "databases scanned : $n"
echo "NO_DUMP           : $nodump"
echo "CANDIDATE rows    : $cand   (a database with >=1 signed-atom-KIND index typespec)"
[ "$n" -gt 0 ] || { echo "REFUSING TO REPORT: the census read NO databases"; exit 5; }
echo "---- candidates"
grep '^CAND' "$OUT" | cut -f2,3
