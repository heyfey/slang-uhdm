#!/bin/bash
# r11u222map: the r11u218 cross-section: the law218 gate sweep's ($LSW) STRICT_NOTEQUAL rows and cases re-dumped and
# re-keyed into $WS (jobs.py over the law sweep's csvs; probe jobs from $W/probejobs.tsv with the law sweep's databases).
DR=$(cd "$(dirname "$0")" && pwd); . $DR/env.sh
mkdir -p ${WS:?}; cd $WS; export SCMP=$B/strictcmp_x R11U138_TMP=$WS/tmp; mkdir -p tmp
python3 $DR/jobs.py ${LSW:?}/surelog.csv $LSW/uhdm2rtlil.csv $LSW jobs_int.tsv
python3 -c "
import csv
P={r['case']:r for r in csv.DictReader(open('$LSW/probe.csv'))}
with open('probe_ne.tsv','w') as f:
    for l in open('$W/probejobs.tsv'):
        c,m,n,g,o,rel=l.rstrip('\n').split('\t')
        if P[rel]['status']=='STRICT_NOTEQUAL': f.write('\t'.join([c,m,n,g,'$LSW/probe/'+n+'.uhdm',rel])+'\n')"
wc -l probe_ne.tsv
awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | DUMPS=$WS/dumps xargs -P3 -n5 $DR/run1.sh
awk -F'\t' '{print $1,$2,$3,$4,$5}' probe_ne.tsv | DUMPS=$WS/pdumps xargs -P3 -n5 $DR/run1.sh
python3 $DR/analyze.py jobs_int.tsv corpus.jsonl $WS/dumps 3
python3 $DR/analyze.py probe_ne.tsv probe.jsonl $WS/pdumps 3
echo WS_DONE
