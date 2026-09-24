#!/usr/bin/env python3
"""tsall.py <pairs.tsv> <ctxregex> : every paired ref_typespec whose walk context matches, both names."""
import sys, subprocess, re, collections, concurrent.futures as cf
TS='/tmp/r11u133_x/drv/tsref'
rx=re.compile(sys.argv[2])
def run(p):
    try: return subprocess.run([TS,p],capture_output=True,text=True,timeout=600).stdout.splitlines()
    except Exception: return []
def one(line):
    lab,g,o=line.rstrip('\n').split('\t')[:3]
    A=[l.split('\t') for l in run(g)]; B=[l.split('\t') for l in run(o)]
    out=[]
    if len(A)!=len(B): return lab,[('COUNTDIFF',)]
    for a,b in zip(A,B):
        if rx.search(a[3]): out.append((a[2],b[2],a[0],b[0],a[1],re.sub(r'@[0-9:-]+','',a[3])))
    return lab,out
lines=open(sys.argv[1]).readlines()
with cf.ThreadPoolExecutor(8) as ex:
    for lab,out in ex.map(one,lines):
        for o in out: print(lab+'\t'+'\t'.join(o))
