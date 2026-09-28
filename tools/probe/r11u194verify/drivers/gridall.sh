#!/bin/bash
# (r11u194: adapted from r11u190verify/drivers/gridall.sh) gridall.sh <outdir> [--el] [case-glob]: grid.py over every
# case of cases/ (X with --pairs), four at a time; one output file per case.
source "$(dirname "$0")/env.sh" || exit 2
O=$1; EL=${2:-}; G=${3:-cases/*/*}; mkdir -p $O
cd $R194_DIR
ls -d $G | sort | xargs -P ${GP:-3} -I{} bash -c 'p=""; case {} in cases/X/*) p=--pairs;; esac; python3 drivers/grid.py '"$EL"' $p {} > '"$O"'/$(echo {} | tr / _).txt 2>&1'
cat $O/*.txt > $O.all.txt
