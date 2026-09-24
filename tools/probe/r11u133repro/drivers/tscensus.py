#!/usr/bin/env python3
"""tscensus.py <pairs.tsv> : pairs.tsv lines 'label<TAB>golden<TAB>ours'. Runs tsref on both,
pairs ref_typespec lines by index (when counts equal, else by ctx multiset), and prints every
pair where the full names differ, classified. Measurement only (r11u133)."""
import sys, subprocess, re, collections, concurrent.futures as cf
TS='/tmp/r11u133_x/drv/tsref'
def run(p):
    try: return subprocess.run([TS,p],capture_output=True,text=True,timeout=600).stdout.splitlines()
    except Exception: return []
def strip(ctx): return re.sub(r'@[0-9:-]+','',ctx)
def one(line):
    lab,g,o=line.rstrip('\n').split('\t')
    A=[l.split('\t') for l in run(g)]; B=[l.split('\t') for l in run(o)]
    out=[]
    if len(A)==len(B):
        pairs=list(zip(A,B))
    else:
        byk=collections.defaultdict(list)
        for b in B: byk[b[3]].append(b)
        pairs=[]
        for a in A:
            if byk[a[3]]: pairs.append((a,byk[a[3]].pop(0)))
    for a,b in pairs:
        if a[2]!=b[2]:
            gp=a[0]; op=b[0]
            gcls=re.sub(r'@[0-9:-]+','',gp)
            ocls=re.sub(r'@[0-9:-]+','',op)
            out.append((lab,gcls,ocls,a[2],b[2],a[1],strip(a[3])))
    return lab,len(A),len(B),out
lines=open(sys.argv[1]).readlines()
with cf.ThreadPoolExecutor(6) as ex:
    for lab,na,nb,out in ex.map(one,lines):
        for o in out: print('\t'.join(o))
