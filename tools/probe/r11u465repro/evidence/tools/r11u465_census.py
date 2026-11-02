import os,re,sys
fen=[l.strip() for l in open('/tmp/r11u465_fenced.txt') if l.strip()]
rx=re.compile(rb'^import\s+[\w$]+::',re.M)
def bad(p): return any(f in p for f in fen)
def scan_dir(d):
    hits=[]
    paths=[]
    for r,ds,fs in os.walk(d):
        for f in fs:
            if f.endswith(('.sv','.v','.svh','.vh','.pkg','.svp')): paths.append(os.path.join(r,f))
    paths=[p for p in paths if not bad(p)]
    for p in paths:
        try: b=open(p,'rb').read()
        except: continue
        if rx.search(b): hits.append(p)
    return hits
out=open(sys.argv[1],'w')
root='/home/heyfey/git-repos/slang-uhdm'
# surelog corpus: rows of results/golden_surelog.csv
import csv
for corp,csvf,bases in [('surelog',root+'/results/golden_surelog.csv',[root+'/third_party/Surelog/tests',root+'/third_party/Surelog/third_party/tests']),('uhdm2rtlil',root+'/results/golden_uhdm2rtlil.csv',[root+'/third_party/uhdm2rtlil/test'])]:
    names=set()
    for row in csv.reader(open(csvf)):
        if row and row[0] not in ('test','name','case'): names.add(row[0])
    for n in sorted(names):
        if bad(n): continue
        for b in bases:
            d=os.path.join(b,n)
            if os.path.isdir(d):
                h=scan_dir(d)
                if h: out.write(f'{corp} {n} {len(h)}\n')
# probe
pd=root+'/tests/probe'
for r,ds,fs in os.walk(pd):
    for f in fs:
        p=os.path.join(r,f)
        if bad(p) or not f.endswith(('.sv','.v','.svh')): continue
        if rx.search(open(p,'rb').read()): out.write(f'probe {os.path.relpath(p,pd)} 1\n')
# sv-tests: absolute source paths in control cmds.txt
sw='/tmp/intr11u462/svtests/work'
for r,ds,fs in os.walk(sw):
    if 'cmds.txt' in fs:
        rel=os.path.relpath(r,sw)
        if bad(rel): continue
        line=[l for l in open(os.path.join(r,'cmds.txt')) if l.startswith('slang:')]
        if not line: continue
        toks=[t for t in line[0].split() if t.startswith('/') and t.endswith(('.sv','.v','.svh'))]
        incs=[t[2:] for t in line[0].split() if t.startswith('-I/')]
        files=[t for t in toks if not bad(t)]
        hit=0
        for t in files:
            try:
                if rx.search(open(t,'rb').read()): hit+=1
            except: pass
        if hit: out.write(f'svtests {rel} {hit}\n')
out.close()
