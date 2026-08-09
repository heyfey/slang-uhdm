#!/bin/bash
# tsdiff15.sh [ours.uhdm] -- r10earl15a on the Earlgrey golden + ours, then the
# A-vs-B projection diff (typespec -> Instance back-edge).
G=/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm
O=${1:-/tmp/r10earl15_aww/default/Earlgrey_0_1-71da2fd7/slang.uhdm}
/tmp/r10earl15a "$G" "$O" > /tmp/r10earl15_ts.txt 2>&1
grep '^A ' /tmp/r10earl15_ts.txt | cut -c3- | sort > /tmp/r10earl15_tsA.txt
grep '^B ' /tmp/r10earl15_ts.txt | cut -c3- | sort > /tmp/r10earl15_tsB.txt
wc -l /tmp/r10earl15_tsA.txt /tmp/r10earl15_tsB.txt
diff /tmp/r10earl15_tsA.txt /tmp/r10earl15_tsB.txt > /tmp/r10earl15_tsdiff.txt
echo "diff lines: $(wc -l < /tmp/r10earl15_tsdiff.txt)"
