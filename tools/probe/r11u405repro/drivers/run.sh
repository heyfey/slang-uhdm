#!/bin/bash
# run.sh <binary> <listfile> <outdir>
cd /home/heyfey/git-repos/slang-uhdm
export SLANG_UHDM=$1 SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
rm -rf $3; mkdir -p $3
python3 scripts/svtests/svtests_matrix.py --svtests /home/heyfey/git-repos/sv-tests --out $3/m.csv --workroot $3/work --jobs 3 --paths-file $2 --keep-golden --uvm-dir third_party/Surelog/third_party/UVM/1800.2-2017-1.0 > $3/log 2>&1
python3 - $3/m.csv <<'P'
import csv,sys
g={r['case']:r for r in csv.DictReader(open('/home/heyfey/git-repos/slang-uhdm/results/golden_svtests.csv'))}
for r in csv.DictReader(open(sys.argv[1])):
    a=r['agreement']; b=g[r['path']]['status']
    m={'IDENTICAL':'EQUAL','JUDGE_EQUAL':'STRICT_NOTEQUAL'}.get(a,a)
    if m!=b: print('MOVE',r['path'],b,'->',m,r['strict'])
P
