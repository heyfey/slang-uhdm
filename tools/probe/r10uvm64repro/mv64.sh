#!/usr/bin/env bash
# r10uvm64 PER-SHAPE MOVER ANALYSIS.
#
#   usage: mv64.sh <golden.uhdm> <pristine.uhdm> <patched.uhdm> <label>
#
# THREE numbers, and they answer three DIFFERENT questions.  Conflating them is
# how a pass reports "the dump got closer" while the comparator got further:
#
#   1. MULTISET DISTANCE TO GOLDEN, before and after (msdist.sh).  This is the
#      only distance this campaign trusts — `diff -u | grep -c` is an LCS
#      measure and moves by thousands on a re-alignment.  LHS is ALWAYS golden.
#   2. ADDED / REMOVED LINE SHAPES, pristine -> patched, reported SEPARATELY and
#      never netted.  A law claimed to be ADD-ONLY is falsified by a single
#      REMOVED shape, and a net figure would hide it.
#   3. The ADDED shapes THEMSELVES, normalised (ids and spans stripped) and
#      counted.  "7 lines added" is not a finding; "7 x `|vpiSigned:1`" is.
#
#   4. THE THREE-WAY COUNT of each added line TEXT: golden / pristine / patched.
#      THIS IS THE ONLY HONEST READING OF THE DISTANCE, and the reason this
#      instrument was corrected mid-pass rather than believed.
#
# WHY THE DISTANCE CAN RISE ON A CORRECT ADD — measured here, not argued.
# `msdist.sh` compares MULTISETS OF LINE TEXTS.  `  |vpiSigned:1` is one of the
# commonest lines in a UVM dump (tens of thousands of instances), and every
# instance is INTERCHANGEABLE to a multiset.  If OUR dump already carries MORE
# `  |vpiSigned:1` instances than golden — because some OTHER law over-stamps it
# elsewhere — then the multiset already counts that text as an OURS-ONLY
# surplus, and putting the flag on the RIGHT object adds one more instance to a
# surplus instead of filling a deficit.  THE DISTANCE THEN RISES BY 1 PER
# CORRECTLY ADDED LINE.  That is a property of the instrument, not of the patch:
# the multiset cannot see WHICH object holds the line, which is exactly the
# blindness `uhdm-cmp` does not have.  So the arithmetic below is REPORTED and
# INTERPRETED against the three-way count; it is never used as a pass/fail.
# THE AUTHORITY ON WHETHER THE RIGHT OBJECT GOT THE FLAG IS uhdm-cmp's HEAD,
# and for a per-object reading `ct64cells.py` is the instrument.
#
# GUARDS: uhdm-dump's first line is the database path -> `sed 1d` on all three.
# A missing or empty dump is exit 6, never a distance of 0.
set -u
G=${1:?golden.uhdm}
P=${2:?pristine.uhdm}
Q=${3:?patched.uhdm}
L=${4:-unnamed}
HERE=$(cd "$(dirname "$0")" && pwd)
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
T=$(mktemp -d /tmp/r64mv.XXXXXX)
for pair in "G:$G" "P:$P" "Q:$Q"; do
  k=${pair%%:*}; f=${pair#*:}
  [ -f "$f" ] || { echo "NO_OUTPUT: missing $k $f"; exit 6; }
  "$DUMP" "$f" 2>/dev/null | sed '1d' > "$T/$k.dump"
  [ -s "$T/$k.dump" ] || { echo "NO_OUTPUT: empty dump for $k $f"; exit 6; }
done
echo "==== $L"
db=$("$HERE/msdist.sh" "$T/G.dump" "$T/P.dump" | sed -n 's/^MULTISET DISTANCE.*: //p')
da=$("$HERE/msdist.sh" "$T/G.dump" "$T/Q.dump" | sed -n 's/^MULTISET DISTANCE.*: //p')
echo "multiset distance to GOLDEN: pristine=$db  patched=$da  gain=$((db-da))"
# ADDED / REMOVED as MULTISETS of whole lines (indentation preserved verbatim —
# uhdm-dump encodes depth as leading spaces and a whitespace-blind key made
# every re-parenting invisible in an earlier build of this instrument).
sort "$T/P.dump" | uniq -c | sed -E 's/^ *([0-9]+) /\1\t/' > "$T/p.cnt"
sort "$T/Q.dump" | uniq -c | sed -E 's/^ *([0-9]+) /\1\t/' > "$T/q.cnt"
awk -F'\t' 'FNR==NR{p[$2]=$1;next}{q[$2]=$1}
  END{
    for (k in q) { d=q[k]-(k in p?p[k]:0); if (d>0) printf "ADDED\t%d\t%s\n", d, k }
    for (k in p) { d=p[k]-(k in q?q[k]:0); if (d>0) printf "REMOVED\t%d\t%s\n", d, k }
  }' "$T/p.cnt" "$T/q.cnt" > "$T/delta"
A=$(awk -F'\t' '$1=="ADDED"{n+=$2} END{print n+0}' "$T/delta")
R=$(awk -F'\t' '$1=="REMOVED"{n+=$2} END{print n+0}' "$T/delta")
echo "ADDED line instances=$A   REMOVED line instances=$R   (never netted)"
echo "-- ADDED shapes (ids/spans stripped):"
awk -F'\t' '$1=="ADDED"{print $3}' "$T/delta" |
  sed -E 's/id:[0-9]+/id:N/g; s/line:[0-9]+:[0-9]+/line:L:C/g; s/endln:[0-9]+:[0-9]+/endln:L:C/g' |
  sort | uniq -c | sort -rn | head -20
if [ "$R" != 0 ]; then
  echo "-- REMOVED shapes (a law claimed ADD-ONLY is falsified by any row here):"
  awk -F'\t' '$1=="REMOVED"{print $3}' "$T/delta" |
    sed -E 's/id:[0-9]+/id:N/g; s/line:[0-9]+:[0-9]+/line:L:C/g; s/endln:[0-9]+:[0-9]+/endln:L:C/g' |
    sort | uniq -c | sort -rn | head -20
fi
echo "-- THREE-WAY COUNT of each added line TEXT (golden / pristine / patched):"
awk -F'\t' '$1=="ADDED"{print $3}' "$T/delta" | sort -u |
while IFS= read -r ln; do
  g=$(grep -Fxc -- "$ln" "$T/G.dump" || true)
  p=$(grep -Fxc -- "$ln" "$T/P.dump" || true)
  q=$(grep -Fxc -- "$ln" "$T/Q.dump" || true)
  if [ "$p" -ge "$g" ]; then
    note="ours ALREADY >= golden before the patch -> each correct add RAISES the multiset distance by 1"
  else
    note="ours was BELOW golden -> each add LOWERS the multiset distance by 1"
  fi
  printf '   %-24s golden=%-7s pristine=%-7s patched=%-7s  %s\n' "[$ln]" "$g" "$p" "$q" "$note"
done
echo "-- arithmetic, REPORTED not asserted: gain=$((db-da)) ADDED=$A REMOVED=$R"
[ "$R" = 0 ] && echo "   ADD-ONLY HOLDS: REMOVED == 0" \
             || echo "   ADD-ONLY FALSIFIED: read the REMOVED shapes above"
rm -rf "$T"
