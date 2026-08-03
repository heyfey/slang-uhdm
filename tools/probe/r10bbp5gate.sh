#!/bin/bash
# r10bbp5: gate diff helper — compare a fresh sweep csv against its committed baseline.
A=$1   # fresh
B=$2   # baseline
sort "$A" > /tmp/r10bbp5_a.srt
sort "$B" > /tmp/r10bbp5_b.srt
echo "lines fresh=$(wc -l < /tmp/r10bbp5_a.srt) baseline=$(wc -l < /tmp/r10bbp5_b.srt)"
diff /tmp/r10bbp5_b.srt /tmp/r10bbp5_a.srt > /tmp/r10bbp5_gate.diff
echo "GATE_DIFF_LINES $(wc -l < /tmp/r10bbp5_gate.diff)"
head -80 /tmp/r10bbp5_gate.diff
