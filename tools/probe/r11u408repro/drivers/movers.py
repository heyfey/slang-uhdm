import csv,sys
g={r['case']:r['status'] for r in csv.DictReader(open('/tmp/wt_r11u408/results/golden_svtests.csv'))}
for r in csv.DictReader(open(sys.argv[1])):
    a=r['agreement']; m={'IDENTICAL':'EQUAL','JUDGE_EQUAL':'STRICT_NOTEQUAL'}.get(a,a)
    if m!=g[r['path']]: print(r['path'],g[r['path']],'->',m)
