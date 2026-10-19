#!/bin/bash
# usage: r11u406_run.sh <binary> <listfile> <tag>   -> /tmp/r11u406_run_<tag>.csv, work /tmp/r11u406_run_<tag>
source /tmp/r11u406_env.sh; export SLANG_UHDM=$1
T=$3; rm -rf /tmp/r11u406_run_$T /tmp/r11u406_run_$T.csv /tmp/r11u406_tr_$T; mkdir -p /tmp/r11u406_tr_$T
export R11U406_TRACE=/tmp/r11u406_tr_$T
cd /tmp/wt_r11u406; timeout 3600 python3 scripts/svtests/svtests_matrix.py --svtests $SVT --out /tmp/r11u406_run_$T.csv --workroot /tmp/r11u406_run_$T --jobs ${JOBS:-3} --paths-file $2 --keep-golden --uvm-dir $UVMDIR 2>&1 | tail -1
python3 - /tmp/r11u406_run_$T.csv <<'PY'
import csv,sys
gold={r['case']:r for r in csv.DictReader(open('/tmp/wt_r11u406/results/golden_svtests.csv'))}
m={'IDENTICAL':'EQUAL','JUDGE_EQUAL':'STRICT_NOTEQUAL'}
for r in csv.DictReader(open(sys.argv[1])):
    st=m.get(r['agreement'],r['agreement']); g=gold.get(r['path'],{}).get('status','?')
    print(('SAME ' if st==g else 'MOVE ')+r['path'],g,'->',st,r['strict'] or r['slang_msg'][:60])
PY
