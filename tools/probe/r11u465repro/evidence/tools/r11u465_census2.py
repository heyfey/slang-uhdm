import os,re,sys,csv
fen=[l.strip() for l in open('/tmp/r11u465_fenced.txt') if l.strip()]
def bad(p): return any(f in p for f in fen)
rxpk=re.compile(rb'^\s*package\s+(\w+)\s*;(.*?)^\s*endpackage',re.M|re.S)
rxim=re.compile(rb'\bimport\s+(\w+)\s*::\s*\*')
def chain(texts):
    imp={}
    for b in texts:
        for m in rxpk.finditer(b):
            imp.setdefault(m.group(1),set()).update(rxim.findall(m.group(2)))
    for p,qs in imp.items():
        for q in qs:
            if imp.get(q): return True
    return False
def files_in(d):
    out=[]
    for r,ds,fs in os.walk(d):
        for f in fs:
            if f.endswith(('.sv','.v','.svh','.vh','.pkg')): out.append(os.path.join(r,f))
    return [p for p in out if not bad(p)]
def rd(ps):
    t=[]
    for p in ps:
        try: t.append(open(p,'rb').read())
        except: pass
    return t
out=open(sys.argv[1],'w'); root='/home/heyfey/git-repos/slang-uhdm'
for corp,csvf,bases in [('surelog',root+'/results/golden_surelog.csv',[root+'/third_party/Surelog/tests',root+'/third_party/Surelog/third_party/tests']),('uhdm2rtlil',root+'/results/golden_uhdm2rtlil.csv',[root+'/third_party/uhdm2rtlil/test'])]:
    names=set(r[0] for r in csv.reader(open(csvf)) if r)
    for n in sorted(names):
        if bad(n): continue
        for b in bases:
            d=os.path.join(b,n)
            if os.path.isdir(d) and chain(rd(files_in(d))): out.write(f'{corp} {n}\n')
pd=root+'/tests/probe'
for r,ds,fs in os.walk(pd):
    for f in fs:
        p=os.path.join(r,f)
        if f.endswith(('.sv','.v')) and not bad(p) and chain(rd([p])): out.write(f'probe {os.path.relpath(p,pd)}\n')
sw='/tmp/intr11u462/svtests/work'
for r,ds,fs in os.walk(sw):
    if 'cmds.txt' in fs:
        rel=os.path.relpath(r,sw)
        if bad(rel): continue
        line=[l for l in open(os.path.join(r,'cmds.txt')) if l.startswith('slang:')]
        if not line: continue
        toks=[t for t in line[0].split() if t.startswith('/') and t.endswith(('.sv','.v','.svh')) and not bad(t) and 'uvm_pkg.sv' not in t]
        incs=[t[2:] for t in line[0].split() if t.startswith('-I/') and 'UVM' not in t]
        fl=toks+[p for d in incs for p in files_in(d)]
        if chain(rd(fl)): out.write(f'svtests {rel}\n')
out.close()
