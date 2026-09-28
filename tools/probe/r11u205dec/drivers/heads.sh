#!/bin/bash
# heads.sh <sweepdir> <outdir> [N]: strict records of every STRICT_NOTEQUAL row-mode of the committed baselines,
# golden = the cache entry cmds.txt names, ours = the sweep's slang.uhdm. Fenced rows refused (fail closed).
. /tmp/wt_r11u205/tools/probe/r11u205dec/drivers/env.sh || exit 1
SW=$1; OUT=$2; N=${3:-60}; mkdir -p $OUT
for corp in surelog uhdm2rtlil; do
  grep ',STRICT_NOTEQUAL,' $WT/results/golden_$corp.csv | while IFS=, read name mode rest; do
    if echo "$name" | grep -qwE "$FENCE_RE"; then echo "FENCED-SKIP"; continue; fi
    d=$(ls -d $SW/$corp/$mode/$name-*/ 2>/dev/null | head -1); [ -n "$d" ] || { echo "MISSING $corp $mode $name"; continue; }
    g=$(grep -o 'golden cache [a-z]* *[^ )]*' $d/cmds.txt | awk '{print $NF}'); [ -f "$g/golden.uhdm" ] || g=$(dirname $(grep -o '/[^ ]*golden.uhdm' $d/cmds.txt|head -1))
    timeout 600 $STRICT_CMP --max $N --dump-a $OUT/$name.$mode.gold.rec --dump-b $OUT/$name.$mode.ours.rec $g/golden.uhdm $d/slang.uhdm > $OUT/$name.$mode.txt 2>&1
    echo "$corp $mode $name rc=$? $(tail -1 $OUT/$name.$mode.txt)"
  done
done
