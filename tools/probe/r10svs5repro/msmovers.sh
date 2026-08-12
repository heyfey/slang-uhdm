#!/bin/bash
# r10svs5repro/msmovers.sh — PER-SHAPE MOVER ATTRIBUTION BY MULTISET, 3-way.
#
# This is the instrument the standing brief mandates in place of `diff -u`
# counting. The integration that produced this rule watched `diff -u` read
# 39 ADDED / 109 REMOVED on a mover whose TRUE multiset was 70 removed / 0 added
# (a pure relocation stacked on top): `diff -u` reports an ALIGNMENT, and an
# alignment shift re-prints unchanged content as both - and +.
#
# For every dump line whose COUNT changed between the pristine and the patched
# run, print:
#     G=<count in golden>  P=<count pristine-ours>  A=<count patched-ours>  <line>
# and classify it:
#     CONVERGED  |A-G| < |P-G|   (we moved TOWARD golden)
#     DIVERGED   |A-G| > |P-G|   (we moved AWAY -- a regression)
#     LATERAL    |A-G| = |P-G|   (equal distance, different shape)
# ADDED (P=0) and REMOVED (A=0) are reported SEPARATELY, as the brief requires,
# rather than summed into one "changed" number.
#
#   usage: msmovers.sh <golden.dump> <pristine_ours.dump> <patched_ours.dump>
#
# GUARDS:
#   * all three inputs are non-empty-checked; a missing dump is exit 6, never a
#     silent "no movers" (which reads exactly like a clean run).
#   * uhdm-dump's FIRST LINE is the database path and always differs -- the
#     inputs must ALREADY be `sed 1d`-stripped (svsgen.sh/svsarm.sh do that).
#   * INDENTATION IS PRESERVED. uhdm-dump encodes object DEPTH as leading
#     spaces, and the whitespace-blind version of this key (`awk '{$1=""}'`)
#     is the defect r10uvm57 found in msdist.sh after three commit messages had
#     already quoted its numbers. The key here is built with `cut`, never with
#     an awk field reassignment.
set -u
G=${1:?golden dump}
P=${2:?pristine ours dump}
A=${3:?patched ours dump}
for f in "$G" "$P" "$A"; do
  [ -s "$f" ] || { echo "NO_OUTPUT: missing or empty $f"; exit 6; }
done
T=$(mktemp -d)
key() { LC_ALL=C sort "$1" | LC_ALL=C uniq -c |
        sed -E 's/^ *([0-9]+) /\1\t/' > "$2"; }
key "$G" "$T/g"; key "$P" "$T/p"; key "$A" "$T/a"
# join on the LINE (field 2..) using a tab-separated count field.
awk -F'\t' '
  FILENAME==ARGV[1] { g[$2]=$1; seen[$2]=1; next }
  FILENAME==ARGV[2] { p[$2]=$1; seen[$2]=1; next }
                    { a[$2]=$1; seen[$2]=1 }
  END {
    conv=0; div=0; lat=0; add=0; rem=0
    for (l in seen) {
      if (p[l]+0 == a[l]+0) continue
      dp = p[l]+0 - g[l]+0; if (dp < 0) dp = -dp
      da = a[l]+0 - g[l]+0; if (da < 0) da = -da
      cls = (da < dp) ? "CONVERGED" : ((da > dp) ? "DIVERGED" : "LATERAL")
      if (p[l]+0 == 0) { add++; kind="ADDED" }
      else if (a[l]+0 == 0) { rem++; kind="REMOVED" }
      else { kind="RECOUNT" }
      printf "%-9s %-7s G=%d P=%d A=%d  %s\n", cls, kind, g[l]+0, p[l]+0, a[l]+0, l
      if (cls=="CONVERGED") conv++; else if (cls=="DIVERGED") div++; else lat++
    }
    printf "---- shapes whose count moved: %d   CONVERGED=%d DIVERGED=%d LATERAL=%d\n", conv+div+lat, conv, div, lat
    printf "---- ADDED (absent in pristine): %d    REMOVED (absent in patched): %d   [reported SEPARATELY]\n", add, rem
  }
' "$T/g" "$T/p" "$T/a" | LC_ALL=C sort
rm -rf "$T"
