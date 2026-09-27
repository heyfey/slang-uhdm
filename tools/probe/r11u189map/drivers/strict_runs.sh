#!/bin/bash
DR=/tmp/wt_r11u189/tools/probe/r11u189map/drivers
. $DR/env.sh
cd /tmp/r11u189_W; export R11U138_TMP=/tmp/r11u189_W/tmp SCMP=/tmp/r11u189_bin/strictcmp_x
mkdir -p tmp
awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | DUMPS=/tmp/r11u189_W/dumps xargs -P3 -n5 $DR/run1.sh
echo CORPUS_DONE
awk -F'\t' '{print $1,$2,$3,$4,$5}' probejobs.tsv | DUMPS=/tmp/r11u189_W/pdumps xargs -P3 -n5 $DR/run1.sh
echo PROBE_DONE
