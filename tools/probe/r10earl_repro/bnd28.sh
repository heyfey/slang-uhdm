#!/bin/bash
# bnd25.sh <tag> [ours.uhdm] -- the WHOLE-ARENA ref_obj BIND census
# (r10earl22a with an empty selector over every line), the pass-22..25
# regression check for over/under-binding.  Prints the per-shape counts.
G=${EARL_GOLD:-/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm}
O=${2:-${EARL_OURS:-/tmp/r10earl28_e2w/default/Earlgrey_0_1-71da2fd7/slang.uhdm}}
T=${1:-base}
/tmp/r10e28_22a "$G" "$O" '' 0 999999 > "/tmp/r10earl28_bnd_$T.txt" 2>&1
echo "rc=$? -> /tmp/r10earl28_bnd_$T.txt"
grep -v absent "/tmp/r10earl28_bnd_$T.txt" | grep -c .
echo "--- shape tallies"
grep -v absent "/tmp/r10earl28_bnd_$T.txt" | sed -E 's/^[^ ]+ +//' \
  | awk '{print $NF, $(NF-1)}' | sort | uniq -c | sort -rn | head -20
