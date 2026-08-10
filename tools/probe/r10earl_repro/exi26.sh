#!/bin/bash
# exi25.sh <tag> [ours.uhdm] -- r10earl23a WHOLE-ARENA EXISTENCE census
# ("does this object exist at all, and with what type?"), reduced to the two
# EXIT METRICS the handoff tracks: total keys and DIFF rows (golden-only +
# ours-only).  It is an UPPER BOUND — it includes fullname-spelling differences
# uhdm-cmp never reads.
G=${EARL_GOLD:-/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm}
O=${2:-${EARL_OURS:-/tmp/r10earl26_e2w/default/Earlgrey_0_1-71da2fd7/slang.uhdm}}
T=${1:-base}
/tmp/r10e26_23a "$G" "$O" '' > "/tmp/r10earl26_exi_$T.txt" 2>&1
echo "rc=$? -> /tmp/r10earl26_exi_$T.txt"
# NOTE the row shape is `DIFF G=xN O=xM  <type>  <fullname> @line:col`, so the
# EXCESS is a COUNT delta, not a presence flag — sum |N-M| per side, which is
# what the handoff's "golden-only / ours-only" numbers are.
echo "keys:      $(grep -c . "/tmp/r10earl26_exi_$T.txt")"
echo "DIFF rows: $(grep -c '^DIFF' "/tmp/r10earl26_exi_$T.txt")"
grep '^DIFF' "/tmp/r10earl26_exi_$T.txt" \
  | sed -E 's/^DIFF G=x([0-9]+) O=x([0-9]+).*/\1 \2/' \
  | awk '{if($1>$2)g+=$1-$2; else o+=$2-$1} END {print "  golden-only objects: "g"\n  ours-only objects:   "o}'
