#!/usr/bin/env python3
"""anc.py <dumpA> <dumpB> <n> [ctx] : records n (0-based) of both strict dumps with their ancestors."""
import sys
def load(f): return [l.split('\x1f')[0].split('\t') for l in open(f).read().split('\n') if l]
def anc(L,n):
    d=int(L[n][0]); out=[]
    for i in range(n-1,-1,-1):
        dd=int(L[i][0])
        if dd<d: out.append(L[i][1]+'('+L[i][2]+')'+'@'+L[i][6]+':'+L[i][7]); d=dd
        if d==0: break
    return ' < '.join(out)
A=load(sys.argv[1]); B=load(sys.argv[2]); n=int(sys.argv[3]); k=int(sys.argv[4]) if len(sys.argv)>4 else 0
for i in range(max(0,n-k), n+k+1):
    for tag,L in (('G',A),('O',B)):
        if i < len(L): print(tag, i, ' '.join(L[i][:15]), '|', anc(L,i) if i==n else '')
