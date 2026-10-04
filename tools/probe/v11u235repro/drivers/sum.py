#!/usr/bin/env python3
# v11u235: sum.py <grid out>: one line per case-view: pristine and law status, exit codes, OFF!=P (switch-off not pristine), MOVED (law bytes differ).
import sys,collections,re
rows=collections.defaultdict(dict)
for l in open(sys.argv[1]):
    p=l.split()
    if len(p)<3: continue
    k=p[0].replace('',''); t=p[1]
    d=dict(x.split('=',1) for x in p[2:] if '=' in x); d['raw']=' '.join(p[2:])
    rows[k][t]=d
def st(d):
    if 'cmp' not in d: return d['raw'].split()[0]
    if d['cmp']!='0': return 'S1(%s)'%d['cmplines']
    return d['strict']
for k in sorted(rows):
    r=rows[k]; P=r.get('P',{});L=r.get('L',{});O=r.get('O',{});O5=r.get('O5',{})
    flag=[]
    if P.get('md5')!=O.get('md5'): flag.append('OFF!=P')
    if P.get('md5')!=L.get('md5'): flag.append('MOVED')
    rcs={x.get('rc') for x in (P,L,O,O5)}
    print(f"{k:22} P={st(P):40} L={st(L):40} rc={','.join(sorted(map(str,rcs)))} {' '.join(flag)}")
