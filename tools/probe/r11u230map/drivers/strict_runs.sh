#!/bin/bash
# strict runs with record dumps over the HEAD sweep ($MAP_H, read-only): every STRICT_NOTEQUAL row-mode, then every
# STRICT_NOTEQUAL probe case. Needs $W/jobs_int.tsv and $W/probejobs.tsv (jobs.py, probejobs.py + the NE filter).
# env: SP_CORPUS / SP_PROBE (parallel jobs; default 2 / 3: memory)
DR=$(cd "$(dirname "$0")" && pwd); . "$DR/env.sh"
[ -x "$B/strictcmp_x" ] || { echo "strict_runs: no strictcmp_x in $B" >&2; exit 2; }
cd "$W"; export R11U138_TMP=$W/tmp SCMP=$B/strictcmp_x
mkdir -p tmp
awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | DUMPS=$W/dumps xargs -P${SP_CORPUS:-2} -n5 "$DR/run1.sh"
echo CORPUS_DONE
awk -F'\t' '{print $1,$2,$3,$4,$5}' probejobs.tsv | DUMPS=$W/pdumps xargs -P${SP_PROBE:-3} -n5 "$DR/run1.sh"
echo PROBE_DONE
