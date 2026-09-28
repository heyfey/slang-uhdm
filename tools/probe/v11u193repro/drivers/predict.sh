#!/bin/bash
# predict.sh <mirror (fenced-free) root> <sweep workdir for probe> <out> : refinement predictor over law-sweep databases
. "$(dirname "$0")/env.sh" || exit 3
M=$1; W=$2; O=$3; : > $O; skipped=0; n=0
while read -r f; do row=$(basename $(dirname $f)); row=${row%-*}; v193_fenced "$row" && { skipped=$((skipped+1)); continue; }
  n=$((n+1)); r=$($V193_BIN/predict $M/$f 2>/dev/null | tr '\n' ' '); [ -n "$r" ] && echo "$f $r" >> $O; done < <(cd $M && find surelog uhdm2rtlil -name slang.uhdm | sort)
for u in $W/probe/*.uhdm; do nm=$(basename $u .uhdm); v193_fenced "$nm" && { skipped=$((skipped+1)); continue; }
  n=$((n+1)); r=$($V193_BIN/predict $u 2>/dev/null | tr '\n' ' '); [ -n "$r" ] && echo "probe $nm $r" >> $O; done
echo "scanned=$n fenced_skipped=$skipped" >> $O
