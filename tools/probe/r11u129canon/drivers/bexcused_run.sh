#!/bin/bash
# bexcused_run.sh <pairs.tsv> <out.tsv>: how often mode 4's (b) test fires on every pair (golden first).
# Columns: corpus/test/mode refroot_positions span_differs excused kept
awk -F'\t' '{print $1"/"$3"/"$2"\t"$4"\t"$5}' "$1" | xargs -P 3 -d '\n' -I{} bash -c 'IFS=$'"'"'\t'"'"' read k g o <<< "{}"; /tmp/r11u129_bin/bexcused_g "$g" "$o" "$k"' > "$2"
awk -F'\t' '{r+=$2; d+=$3; e+=$4; k+=$5; if($4>0) er++} END{print NR, "pairs; ref-reached named-root positions", r, "; span differs", d, "; excused", e, "in", er, "row-modes; kept", k}' "$2"
