#!/bin/bash
# strict runs with record dumps over the HEAD sweep ($MAP_H, read-only): every STRICT_NOTEQUAL row-mode, then every
# probe case. Needs $W/jobs_int.tsv and $W/probejobs.tsv (jobs.py, probejobs.py).
DR=$(cd "$(dirname "$0")" && pwd); . "$DR/env.sh"
cd "$W"; export R11U138_TMP=$W/tmp SCMP=$B/strictcmp_x
mkdir -p tmp
awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | DUMPS=$W/dumps xargs -P3 -n5 "$DR/run1.sh"
echo CORPUS_DONE
awk -F'\t' '{print $1,$2,$3,$4,$5}' probejobs.tsv | DUMPS=$W/pdumps xargs -P3 -n5 "$DR/run1.sh"
echo PROBE_DONE
