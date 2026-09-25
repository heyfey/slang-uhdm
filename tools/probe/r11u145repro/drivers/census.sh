#!/bin/bash
# census.sh <mode> <pairs.tsv> <outdir> [ours-col-override-dir]: run cen145 on golden and ours of every pair
m=$1; P=$2; O=$3; mkdir -p $O
run1(){ l="$1"; m=$2; O=$3; IFS=$'\t' read lab g o st sc <<< "$l"; k=$(echo $lab | tr '/' '_');
  /tmp/r11u145_bin/cen145 $m $g > $O/$k.g 2>/dev/null; /tmp/r11u145_bin/cen145 $m $o > $O/$k.o 2>/dev/null; }
export -f run1
cat $P | xargs -d '\n' -P 3 -I{} bash -c 'run1 "$@"' _ {} $m $O
