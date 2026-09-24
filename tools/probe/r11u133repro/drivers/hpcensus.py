#!/usr/bin/env python3
"""hpcensus.py <pairs.tsv> : hier_path element census (golden vs ours), paired by walk order.
Prints one line per element: label pos kind prevkind gname oname gspan ospan hpname ctx."""
import sys, subprocess, re, concurrent.futures as cf
HP='/tmp/r11u133_x/drv/hpref'
def run(p):
    try: out=subprocess.run([HP,p],capture_output=True,text=True,timeout=600).stdout.splitlines()
    except Exception: return None
    hps=[]
    for l in out:
        f=l.split('\t')
        if f[0]=='HP': hps.append((f,[]))
        elif f[0]=='E' and hps: hps[-1][1].append(f)
    return hps
def kind(t): return re.sub(r'\(.*','',t)
def one(line):
    lab,g,o=line.rstrip('\n').split('\t')[:3]
    A=run(g); B=run(o)
    if A is None or B is None or len(A)!=len(B): return lab,[('COUNTDIFF',)]
    out=[]
    for (ha,ea),(hb,eb) in zip(A,B):
        if len(ea)!=len(eb) or ha[1]!=hb[1]: out.append(('HPDIFF',ha[1],hb[1])); continue
        for i,(a,b) in enumerate(zip(ea,eb)):
            n=len(ea); pos='first' if i==0 else ('last' if i==n-1 else 'mid')
            prev=kind(ea[i-1][2]) if i>0 else '-'
            out.append((pos,kind(a[2]),prev,a[3],b[3],a[4],b[4],ha[1],re.sub(r'\([^)]*\)','',ha[4])))
    return lab,out
lines=open(sys.argv[1]).readlines()
with cf.ThreadPoolExecutor(8) as ex:
    for lab,out in ex.map(one,lines):
        for o in out: print(lab+'\t'+'\t'.join(o))
