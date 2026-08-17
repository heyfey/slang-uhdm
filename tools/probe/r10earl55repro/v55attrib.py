#!/usr/bin/env python3
"""r10earl55 ADVERSARIAL VERIFIER (v55) three-way attribution — written from
scratch rather than reusing attrib55.py, so the pass's AWAY-GOLDEN = 0 claim is
confirmed by an independent joiner over an independent (stricter) census.

Reads two `v55census --all` outputs (golden-vs-pristine, golden-vs-patched) and
splits every PAIRED cell into the four outcomes a two-way diff conflates.
AWAY-GOLDEN (pristine right -> patched wrong) is the only regression class.

MEASURED: AWAY-GOLDEN = 0 and STILL-WRONG = 0 on all ELEVEN arms (a1-a5 and the
verifier's v1-v6) in BOTH the elab and the plain view, and on Earlgrey_0_1
default (TO-GOLDEN 1, the predicted cell, over 10 822 paired cells)."""
import sys, re

def load(path):
    cells = {}
    lines = open(path).read().splitlines()
    i = 0
    while i < len(lines):
        L = lines[i]
        if L.startswith('AGREE  '):
            k = L[7:].split('  ', 1)[0]
            rest = L[7:].split('  ', 1)[1] if '  ' in L[7:] else ''
            cells[k] = ('AGREE', rest, rest)
        elif L.startswith('DISAGREE '):
            k = L[9:].rsplit(' [', 1)[0]
            g = lines[i+1].strip() if i+1 < len(lines) else ''
            o = lines[i+2].strip() if i+2 < len(lines) else ''
            cells[k] = ('DISAGREE', g, o)
            i += 2
        i += 1
    return cells

pris = load(sys.argv[1]); pat = load(sys.argv[2])
keys = set(pris) | set(pat)
out = {'UNMOVED-GOOD':[], 'TO-GOLDEN':[], 'AWAY-GOLDEN':[], 'STILL-WRONG':[],
       'UNMOVED-BAD':[], 'KEY-ONLY-PRISTINE':[], 'KEY-ONLY-PATCHED':[]}
for k in sorted(keys):
    a = pris.get(k); b = pat.get(k)
    if a is None: out['KEY-ONLY-PATCHED'].append((k, '', str(b))); continue
    if b is None: out['KEY-ONLY-PRISTINE'].append((k, str(a), '')); continue
    if a[0]=='AGREE' and b[0]=='AGREE': out['UNMOVED-GOOD'].append((k,'',''))
    elif a[0]=='DISAGREE' and b[0]=='AGREE': out['TO-GOLDEN'].append((k,a[2],b[1]))
    elif a[0]=='AGREE' and b[0]=='DISAGREE': out['AWAY-GOLDEN'].append((k,a[1],b[2]))
    else:
        if a[2]!=b[2]: out['STILL-WRONG'].append((k,a[2],b[2]))
        else: out['UNMOVED-BAD'].append((k,a[1],a[2]))
for cls in ['AWAY-GOLDEN','STILL-WRONG','TO-GOLDEN','KEY-ONLY-PRISTINE','KEY-ONLY-PATCHED','UNMOVED-BAD','UNMOVED-GOOD']:
    print(f"{cls:20s} {len(out[cls])}")
for cls in ['AWAY-GOLDEN','STILL-WRONG','TO-GOLDEN','KEY-ONLY-PRISTINE','KEY-ONLY-PATCHED']:
    for k,x,y in out[cls][:60]:
        print(f"  [{cls}] {k}\n      pris: {x}\n      pat : {y}")
