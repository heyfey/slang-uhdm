#!/bin/bash
# r10bpfam: resolve golden+ours for a (workdir-tag, mode, test) and run a probe.
# Usage: r10bpfamcmp.sh <wtag> <mode> <TestName> [probe-binary]   (default probe = 14a)
W=/tmp/r10bpfam_w$1; MODE=$2; T=$3; PROBE=${4:-/tmp/r10bpfam_14a}
D=$(ls -d $W/$MODE/$T-* 2>/dev/null | head -1)
if [ -z "$D" ]; then echo "no workdir for $T/$MODE"; exit 1; fi
G=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' $D/cmds.txt | head -1)
GU=$(find $G -name '*.uhdm' | head -1)
echo "GOLDEN=$GU"
echo "OURS=$D/slang.uhdm"
$PROBE "$GU" "$D/slang.uhdm"
