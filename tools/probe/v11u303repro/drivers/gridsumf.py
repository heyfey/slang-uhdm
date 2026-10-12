#!/usr/bin/env python3
# v11u303 gridsumf.py <grid.txt>: per case-view P, L and F verdicts with exit codes; whether OFF (R11U303_OFF on the
# fix) gives P's bytes and exit code, whether VOFF (R11V303_OFF on the fix) gives L's; which single switch restores P
# (law movers) and which restores L (fix-vs-law movers); totals.
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    p = l.split()
    if len(p) < 3: continue
    cfg, rel = p[0], p[1]
    kv = dict(x.split('=', 1) for x in p[3:] if '=' in x)
    st = kv.get('strict', '?')
    if 'SURELOG_FAIL' in l: st = 'SURELOG_FAIL'
    if 'SLANG_FAIL' in l: st = 'SLANG_FAIL'
    rows[rel][cfg] = (kv.get('md5', '-'), st, kv.get('rc', '?'), kv.get('cmplines', '-'))
def eq(a, b): return a and b and a[0] == b[0] and a[2] == b[2]
T = collections.Counter(); attrP = collections.Counter(); attrL = collections.Counter()
for rel in sorted(rows):
    r = rows[rel]; P, L, F = r.get('P'), r.get('L'), r.get('F')
    if not (P and L and F): continue
    T['views'] += 1
    mv = not eq(P, F); fl = not eq(F, L)
    if mv: T['F moving vs P'] += 1
    if not eq(P, L): T['L moving vs P'] += 1
    if fl: T['F differs from L'] += 1
    for X, k in ((L, 'L'), (F, 'F')):
        if P[1].startswith('STRICT_EQUAL') is False and X[1].startswith('STRICT_EQUAL'): T[k + ' entering STRICT_EQUAL'] += 1
        if P[1].startswith('STRICT_EQUAL') and not X[1].startswith('STRICT_EQUAL'): T[k + ' leaving STRICT_EQUAL'] += 1
        if P[2] != X[2]: T[k + ' rc change'] += 1
        if P[3] != X[3]: T[k + ' cmplines change'] += 1
    if eq(r.get('OFF'), P): T['OFF==P'] += 1
    if eq(r.get('VOFF'), L): T['VOFF==L'] += 1
    rp = [c.replace('R11U303_', '').replace('R11V303_', 'V:').replace('_OFF', '') for c in r if c.startswith('R11') and mv and eq(r[c], P)]
    rl = [c.replace('R11V303_', '').replace('_OFF', '') for c in r if c.startswith('R11V') and fl and eq(r[c], L)]
    if mv: attrP[','.join(rp) or 'none-alone'] += 1
    if fl: attrL[','.join(rl) or 'none-alone'] += 1
    print(f"{rel:55s} P {P[1]} rc={P[2]} cmp={P[3]} | L {L[1]} rc={L[2]} cmp={L[3]} | F {F[1]} rc={F[2]} cmp={F[3]} | {'MOVES' if mv else 'same'}{' F!=L' if fl else ''} | P-restore: {','.join(rp) or '-'} | L-restore: {','.join(rl) or '-'}")
print('totals:', dict(T)); print('restore P by:', dict(attrP)); print('restore L by:', dict(attrL))
