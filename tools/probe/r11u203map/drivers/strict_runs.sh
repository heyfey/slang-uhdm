#!/bin/bash
# strict runs with record dumps over the HEAD sweep (/tmp/intr11u196, read-only): every STRICT_NOTEQUAL row-mode, then every probe case
DR=$(cd "$(dirname "$0")" && pwd); . $DR/env.sh
cd /tmp/r11u203_W; export R11U138_TMP=/tmp/r11u203_W/tmp SCMP=/tmp/r11u203_bin/strictcmp_x
mkdir -p tmp
awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | DUMPS=/tmp/r11u203_W/dumps xargs -P3 -n5 $DR/run1.sh
echo CORPUS_DONE
awk -F'\t' '{print $1,$2,$3,$4,$5}' probejobs.tsv | DUMPS=/tmp/r11u203_W/pdumps xargs -P3 -n5 $DR/run1.sh
echo PROBE_DONE
