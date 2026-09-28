#!/bin/bash
# the r11u191 cross-section: the law191 gate sweep's STRICT_NOTEQUAL rows and cases re-dumped and re-keyed (WS)
DR=$(cd "$(dirname "$0")" && pwd); . $DR/env.sh
mkdir -p /tmp/r11u197_WS; cd /tmp/r11u197_WS; export SCMP=/tmp/r11u197_bin/strictcmp_x R11U138_TMP=/tmp/r11u197_WS/tmp; mkdir -p tmp
python3 $DR/jobs.py /tmp/r11u197_sL/surelog.csv /tmp/r11u197_sL/uhdm2rtlil.csv /tmp/r11u197_sL jobs_int.tsv
python3 -c "
import csv
P={r['case']:r for r in csv.DictReader(open('/tmp/r11u197_sL/probe.csv'))}
with open('probe_ne.tsv','w') as f:
    for l in open('/tmp/r11u197_W/probejobs.tsv'):
        c,m,n,g,o,rel=l.rstrip('\n').split('\t')
        if P[rel]['status']=='STRICT_NOTEQUAL': f.write('\t'.join([c,m,n,g,'/tmp/r11u197_sL/probe/'+n+'.uhdm',rel])+'\n')"
wc -l probe_ne.tsv
awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | DUMPS=/tmp/r11u197_WS/dumps xargs -P3 -n5 $DR/run1.sh
awk -F'\t' '{print $1,$2,$3,$4,$5}' probe_ne.tsv | DUMPS=/tmp/r11u197_WS/pdumps xargs -P3 -n5 $DR/run1.sh
python3 $DR/analyze.py jobs_int.tsv corpus.jsonl /tmp/r11u197_WS/dumps 3
python3 $DR/analyze.py probe_ne.tsv probe.jsonl /tmp/r11u197_WS/pdumps 3
echo WS_DONE
