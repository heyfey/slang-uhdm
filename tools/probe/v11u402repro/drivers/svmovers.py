#!/usr/bin/env python3
# svmovers.py <wdA> <wdB> : sv-tests slang.uhdm byte movers between two check_svtests workdirs (same-length names, workdir normalised)
import csv, os, sys
A, B = sys.argv[1], sys.argv[2]
P = {r['path']: r for r in csv.DictReader(open(os.path.join(B, 'matrix.csv')))}
L = {r['path']: r for r in csv.DictReader(open(os.path.join(A, 'matrix.csv')))}
for k in sorted(P):
    a = os.path.join(B, 'work', k[:-3], 'slang.uhdm'); b = os.path.join(A, 'work', k[:-3], 'slang.uhdm')
    ea, eb = os.path.exists(a), os.path.exists(b)
    if not ea and not eb: continue
    if ea and eb:
        x = open(a, 'rb').read(); y = open(b, 'rb').read().replace(A.encode() + b'/', B.encode() + b'/')
        if x == y: continue
    print(k, P[k]['agreement'], L[k]['agreement'], 'db' if ea else 'nodb', 'db' if eb else 'nodb')
