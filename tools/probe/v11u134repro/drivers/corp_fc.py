import csv, os, re, glob, subprocess, sys
SC='/tmp/v11u134_bin/strictcmp'
def rows(p): 
    d={}
    for r in csv.DictReader(open(p)): d[(r['name'],r['mode'])]=r
    return d
def dbs(wd, corpus, name, mode):
    ds=glob.glob(f'{wd}/{corpus}/{mode}/{glob.escape(name)}-*/cmds.txt')
    ds=[x for x in ds if os.path.basename(os.path.dirname(x)).rsplit('-',1)[0]==name]
    assert len(ds)==1,(name,mode,ds)
    t=open(ds[0]).read()
    m=re.search(r'golden cache hit (\S+)\)',t)
    g=None
    if m:
        g=glob.glob(m.group(1)+'/*.uhdm')
        g=g[0] if g else None
    o=os.path.dirname(ds[0])+'/slang.uhdm'
    return g,o
def fields(g,o):
    out=subprocess.run([SC,'--max','0',g,o],capture_output=True,text=True,timeout=1800).stdout
    m=re.search(r'^fields: (.*)$',out,re.M); d={}
    if m:
        for k,v in re.findall(r'(\w+)=(\d+)',m.group(1)): d[k]=int(v)
    return d,('walk diverged' in out), out.strip().splitlines()[-1] if out.strip() else ''
for corpus in ('surelog','uhdm2rtlil'):
    P=rows(f'/tmp/v11u134_wdP/{corpus}.csv'); L=rows(f'/tmp/v11u134_wdL/{corpus}.csv')
    assert set(P)==set(L)
    for k in sorted(P):
        if (P[k]['status'],P[k]['strict'])==(L[k]['status'],L[k]['strict']): continue
        g,op=dbs('/tmp/v11u134_wdP',corpus,*k); _,ol=dbs('/tmp/v11u134_wdL',corpus,*k)
        if not g: print('NOGOLDEN',corpus,k); continue
        fp,dp,_=fields(g,op); fl,dl,last=fields(g,ol)
        grow={f:(fp.get(f,0),fl[f]) for f in fl if f!='objects_differing' and fl[f]>fp.get(f,0)}
        print(('GROW ' if grow else 'ok   ')+corpus,k[0],k[1],P[k]['strict'],'->',L[k]['strict'],grow if grow else '','div:%s->%s'%(dp,dl),flush=True)
