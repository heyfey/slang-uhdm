#!/bin/bash
# gridall.sh <outdir> [--el]: grid.py over every case of cases/ (X with --pairs), four at a time; one output file per case.
source /tmp/wt_r11u182/tools/probe/r11u182verify/drivers/env.sh || exit 2
O=$1; EL=${2:-}; mkdir -p $O
cd /tmp/wt_r11u182/tools/probe/r11u182verify
find cases -mindepth 2 -maxdepth 2 -type d | sort | xargs -P 4 -I{} bash -c 'p=""; case {} in cases/X/*) p=--pairs;; esac; python3 drivers/grid.py '"$EL"' $p {} > '"$O"'/$(echo {} | tr / _).txt 2>&1'
cat $O/*.txt > $O.all.txt
