#!/usr/bin/env bash
# r10uvm66 — THE THREE-WAY COUNT OF EVERY **REMOVED** LINE TEXT.
#
#   usage: mvrem66.sh <golden.uhdm> <pristine.uhdm> <patched.uhdm> <label>
#
# WHY THIS EXISTS.  mv66.sh (inherited from mv65.sh) three-way-counts only the
# ADDED texts, because § 65 was an ADD-ONLY law and a removal there would have
# been the falsification, not the mechanism.  § declInitWrittenNewNoStmt66 is a
# DELETE-direction law: it removes ~1200 line instances per UVM database.  For a
# delete the dangerous error is the mirror image of § 65's — deleting PAST
# golden — and the only instrument that can see it is a three-way count of the
# REMOVED texts:
#
#   patched >= golden   the deletion stopped at or above golden's count: SAFE
#   patched <  golden   we deleted something golden HAS: an OVER-DELETE, and the
#                       script prints it and exits 5.
#
# THE FIRST VERSION OF THIS SCRIPT USED THE RULE `patched < golden -> OVER-DELETE`
# AND IT WAS WRONG — it fired 24 times on BuildUVMPkg alone, and every one of the
# 24 was a text OURS WAS ALREADY SHORT OF BEFORE THE PATCH.  A multiset cannot
# see WHICH object holds a line (mv66.sh's header states the mirror-image trap
# for adds), so when pristine is ALREADY BELOW golden a further removal is simply
# NOT DECIDABLE HERE.  Three honest buckets, and the undecidable one says so:
#
#   SURPLUS-ONLY   pristine >= golden AND patched >= golden
#                  the deletion stayed inside our own surplus.  SAFE.
#   CROSSED        pristine >= golden AND patched <  golden
#                  the deletion went PAST golden.  Printed individually; this is
#                  the bucket that can falsify a delete-direction law.
#   ALREADY-SHORT  pristine <  golden
#                  the deficit PRE-DATES the patch; the multiset cannot say
#                  whether the instance removed was the surplus one or a needed
#                  one.  Counted, never called a defect, and referred to the
#                  per-object instruments (ct66cells.py's OVER-FIRE column and
#                  uhdm-cmp's head), which are the authority.
#
# It reports all three and never nets them, exactly as mv66.sh does for adds.
# `sed 1d` on all three dumps (uhdm-dump's first line is the database path).
# A missing or empty dump is exit 6, never a count of 0.
set -u
G=${1:?golden.uhdm}
P=${2:?pristine.uhdm}
Q=${3:?patched.uhdm}
L=${4:-unnamed}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
T=$(mktemp -d /tmp/r66rem.XXXXXX)
for pair in "G:$G" "P:$P" "Q:$Q"; do
  k=${pair%%:*}; f=${pair#*:}
  [ -f "$f" ] || { echo "NO_OUTPUT: missing $k $f"; exit 6; }
  "$DUMP" "$f" 2>/dev/null | sed '1d' > "$T/$k.dump"
  [ -s "$T/$k.dump" ] || { echo "NO_OUTPUT: empty dump for $k $f"; exit 6; }
done
echo "==== $L  (three-way count of REMOVED texts)"
# TWO KEYINGS, and for a DELETE-direction law only the second is authoritative.
#
#   VERBATIM   the line INCLUDING its leading indentation, as mv66.sh keys adds.
#              Correct for an ADD (a minted object appears at one indent and
#              nothing moves), and WRONG for a structural DELETE: removing an
#              enclosing `assignment` lifts every surviving descendant TWO SPACES,
#              so one instance leaves indent N+2 and arrives at indent N.  The
#              verbatim keying reads that single move as a REMOVAL at N+2 and an
#              ADDITION at N, and a CROSSED row here is that artefact far more
#              often than it is a defect.
#   INDENT-BLIND  the line with leading whitespace stripped.  Immune to the lift,
#              and therefore the figure this pass reports.  (It loses the ability
#              to see a pure re-parenting, which is why BOTH are printed.)
for k in G P Q; do
  sort "$T/$k.dump" | uniq -c | sed -E 's/^ *([0-9]+) /\1\t/' > "$T/$k.cnt"
  sed -E 's/^[[:space:]]+//' "$T/$k.dump" | sort | uniq -c |
    sed -E 's/^ *([0-9]+) /\1\t/' > "$T/$k.bcnt"
done
# REMOVED text = one whose instance count FELL from pristine to patched.
buckets() {
  awk -F'\t' -v tag="$1" '
  FNR==NR{g[$2]=$1;next}
  FILENAME==ARGV[2]{p[$2]=$1;next}
  {q[$2]=$1}
  END{
    crossed=0; surplus=0; exact=0; short=0
    for (k in p) {
      d = p[k] - (k in q ? q[k] : 0)
      if (d <= 0) continue
      gc = (k in g ? g[k] : 0); qc = (k in q ? q[k] : 0)
      if (p[k] < gc) { short++; continue }
      if (qc < gc) { crossed++; printf "%s CROSSED\tgolden=%d pristine=%d patched=%d\t%s\n", tag, gc, p[k], qc, k }
      else { surplus++; if (qc == gc) exact++ }
    }
    printf "%s REMOVED texts: %d  SURPLUS-ONLY=%d (of which EXACTLY golden=%d)  CROSSED=%d  ALREADY-SHORT(undecidable here)=%d\n",
           tag, crossed+surplus+short, surplus, exact, crossed, short
    if (crossed > 0) exit 5
  }' "$2" "$3" "$4"
}
buckets VERBATIM     "$T/G.cnt"  "$T/P.cnt"  "$T/Q.cnt"
buckets INDENT-BLIND "$T/G.bcnt" "$T/P.bcnt" "$T/Q.bcnt"
rc=$?
rm -rf "$T"
[ "$rc" = 0 ] && echo "PASS: INDENT-BLIND — no text CROSSED golden" \
              || echo "FAIL: INDENT-BLIND CROSSED rows above (read them; the VERBATIM ones may be the indentation lift)"
exit $rc
