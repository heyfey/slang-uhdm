#!/bin/bash
# sweep.sh <tag> "<ENV1 ENV2 ...>" "<corpora>": one full sweep of the frozen base binary with the named switches set,
# workdir /tmp/r11u143_wd<tag> (tags are two characters: same-length workdirs for byteverify)
source $(dirname $0)/env.sh
for e in $2; do export $e=1; done
W=/tmp/r11u143_wd$1; mkdir -p $W
env | grep -E '^R11[UV]1[34]' | sort > $W/switches.txt
cd /tmp/wt_r11u143 && tests/sweep.sh --jobs 3 --workdir $W --corpus "$3" > $W/sweep.log 2>&1
echo "rc=$?" >> $W/sweep.log
