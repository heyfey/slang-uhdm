#!/usr/bin/env bash
# r10svs7 MOVER ANALYSER -- for ONE database that the byte verifier flagged,
# print (1) the MULTISET distance to GOLDEN before and after, and (2) the
# per-SHAPE ADDED / REMOVED lines between the pristine and the patched database.
#
#   usage: msmovers.sh <golden.uhdm> <pristine/slang.uhdm> <patched/slang.uhdm>
#
# LAWS ENCODED:
#   * uhdm-dump's FIRST LINE is the database PATH and always differs -> `sed 1d`
#     on EVERY dump, golden and ours, pristine and patched.  Never compare the
#     .uhdm BINARIES for shape: they carry ids and arena order.
#   * ADDED and REMOVED are reported SEPARATELY.  A law that adds an object and
#     a law that deletes one are different laws, and a net figure hides both.
#   * A BARE FIELD LINE (`|vpiName:new`, `|vpiParent:`) is NON-ATTRIBUTABLE on
#     its own -- it absorbs into whichever object owns it -- so those are
#     printed in their own section and never counted as object movement.
set -u
G=${1:?golden uhdm}
P=${2:?pristine slang.uhdm}
Q=${3:?patched slang.uhdm}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
T=$(mktemp -d)
for pair in "G:$G" "P:$P" "Q:$Q"; do
    k=${pair%%:*}; f=${pair#*:}
    [ -f "$f" ] || { echo "MISSING $f"; exit 6; }
    "$DUMP" "$f" 2>/dev/null | sed '1d' > "$T/$k.dump"
    [ -s "$T/$k.dump" ] || { echo "EMPTY DUMP for $f"; exit 6; }
done
HERE=$(cd "$(dirname "$0")" && pwd)
echo "---- MULTISET distance to GOLDEN, PRISTINE:"
"$HERE/msdist.sh" "$T/G.dump" "$T/P.dump"
echo "---- MULTISET distance to GOLDEN, PATCHED:"
"$HERE/msdist.sh" "$T/G.dump" "$T/Q.dump"
echo "---- PER-SHAPE movement, pristine -> patched (ours side only)"
sort "$T/P.dump" | uniq -c | sed -E 's/^ *([0-9]+) /\1\t/' > "$T/p.cnt"
sort "$T/Q.dump" | uniq -c | sed -E 's/^ *([0-9]+) /\1\t/' > "$T/q.cnt"
awk -F'\t' '
  FNR==NR { p[$2]=$1; next }
  { q[$2]=$1 }
  END {
    for (k in q) { d = q[k] - (k in p ? p[k] : 0); if (d>0) printf "ADDED   %+d\t%s\n", d, k }
    for (k in p) { d = p[k] - (k in q ? q[k] : 0); if (d>0) printf "REMOVED %+d\t%s\n", d, k }
  }' "$T/p.cnt" "$T/q.cnt" | sed -E 's/\t +/\t/' | sort > "$T/moves"
echo "== OBJECT lines (a dump line beginning with the \\_ object marker):"
grep -E '\\_' "$T/moves" || echo "  (none)"
echo "== BARE FIELD lines (NON-ATTRIBUTABLE absorbers, listed not counted):"
grep -vE '\\_' "$T/moves" || echo "  (none)"
rm -rf "$T"
