#!/usr/bin/env python3
"""cells.py <case workdir> <on tag> <off tag> [-v]: per object and per field, against golden, from the two
uhdm-strictcmp --max 100000 outputs (walk order; an object the output does not list is strict-equal there).
  BROKEN  a field golden-equal in OFF that differs in ON (the object index before both walks' divergence)
  FIXED   a field that differs in OFF and is golden-equal in ON
Fields: depth type name defname fullname file line col endline endcol decompile size value consttype.
A stage-1 state prints STAGE1.  Fail-closed on $FENCED."""
import os, re, sys
if len(os.environ.get('FENCED', '').split()) != 4: sys.exit('cells.py: source drivers/env.sh first')
F = 'depth type name defname fullname file line col endline endcol decompile size value consttype'.split()
def load(p):
    L = open(p, errors='replace').read().split('\n')
    if not L or any('stage1' in l for l in L[-3:]): return None
    recs = {}; div = None
    for i, l in enumerate(L):
        m = re.match(r'#(\d+) (\w+)$', l)
        if m and i + 2 < len(L):
            a = L[i+1].split('A: ', 1)[1].split('\t'); b = L[i+2].split('B: ', 1)[1].split('\t')
            recs[int(m.group(1))] = (m.group(2), a, b)
    if any('walk diverged' in l for l in L) and recs: div = max(recs)
    cnt = [l for l in L if l.startswith('objects ')]
    return recs, div
def main():
    w, on, off = sys.argv[1:4]; verbose = '-v' in sys.argv
    A = load(f'{w}/{on}.strict'); B = load(f'{w}/{off}.strict')
    if A is None or B is None: print('STAGE1', 'on' if A is None else '', 'off' if B is None else ''); return
    (ra, da), (rb, db) = A, B
    lim = min(x for x in (da, db, 10**9) if x is not None)
    broken, fixed = [], []
    for i in sorted(set(ra) | set(rb)):
        if i >= lim: continue
        for k in range(len(F)):
            g = (ra.get(i) or rb.get(i))[1]
            gk = g[k] if k < len(g) else ''
            onv = ra[i][2][k] if i in ra and k < len(ra[i][2]) else gk
            ofv = rb[i][2][k] if i in rb and k < len(rb[i][2]) else gk
            if i in ra and i in rb and ra[i][1] != rb[i][1]: pass
            if onv != gk and ofv == gk: broken.append((i, F[k], gk, ofv, onv))
            if onv == gk and ofv != gk: fixed.append((i, F[k], gk, ofv, onv))
    print(f'BROKEN={len(broken)} FIXED={len(fixed)} lim={"none" if lim == 10**9 else lim} div_on={da} div_off={db}')
    for t, lst in (('BROKEN', broken), ('FIXED', fixed)):
        for x in (lst if verbose or t == 'BROKEN' else lst[:0]):
            print(f'  {t} #{x[0]} {x[1]}: golden={x[2]!r} off={x[3]!r} on={x[4]!r}')
main()
