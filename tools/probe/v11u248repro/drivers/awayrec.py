#!/usr/bin/env python3
# v11u248: awayrec.py <grid.txt> <S> [tagA tagB]: for every case-view of the grid whose bytes move between tagA
# (default pristine) and tagB (default law), the away census both ways: chain-keyed on uhdm-strictcmp's walk
# records (the case.sh dumps $S/g/<cv>/<tag>.{a,b}.rec; key = ancestor chain of type/name plus the record without
# its depth), and, when stage 1 rejects (no records), order-blind on uhdm-dump lines (ids and case paths dropped).
# lost = golden-agreeing keys tagA had and tagB lost; gained = the reverse. Case dumps only; no corpus path.
import os, re, sys, subprocess, collections
grid, S = sys.argv[1:3]; A, Bt = (sys.argv[3:5] if len(sys.argv) > 4 else ('pristine', 'law'))
D = os.environ.get('UHDM_DUMP', '')
if not (D and os.access(D, os.X_OK)): sys.exit('awayrec.py: UHDM_DUMP not executable')
rows = collections.defaultdict(dict)
for l in open(grid):
    f = l.split(); d = dict(x.split('=', 1) for x in f[2:] if '=' in x); rows[f[0]][f[1]] = d
def recs(fn):
    c = collections.Counter(); st = []
    if not os.path.exists(fn): return None
    for l in open(fn):
        x = l.rstrip('\n').split('\t')
        try: dep = int(x[0])
        except ValueError: continue
        st = st[:dep]; key = '/'.join(st) + '|' + '\t'.join(x[1:]); c[key] += 1
        st.append(x[1] + ':' + (x[2] if len(x) > 2 else ''))
    return c
def dump(u):
    out = subprocess.run([D, u], capture_output=True, text=True, errors='replace').stdout
    c = collections.Counter()
    for l in out.splitlines():
        c[re.sub(r'file:\S*/', 'file:', re.sub(r'id:\d+', 'id:', l))] += 1
    return c
for cv, r in sorted(rows.items()):
    a, b = r.get(A), r.get(Bt)
    if not a or not b or a.get('md5') == b.get('md5'): continue
    base = cv[:-3] if cv.endswith('_el') else cv
    w = os.path.join(S, 'g', cv)
    ga, pa, la = recs(f'{w}/{A}.a.rec'), recs(f'{w}/{A}.b.rec'), recs(f'{w}/{Bt}.b.rec')
    if ga and pa and la and sum(ga.values()) and sum(pa.values()) and sum(la.values()):
        G, P, L = ga, pa, la; how = 'chain'
    else:
        gd = [x for x in os.listdir(w) if x.startswith('gold_')]
        G = dump(f'{w}/{gd[0]}/golden.uhdm'); P = dump(f'{w}/{A}.uhdm'); L = dump(f'{w}/{Bt}.uhdm'); how = 'dump'
    lost = (G & P) - L; gained = (G & L) - P
    print(f'{cv} {how} {a.get("strict")} -> {b.get("strict")} dist {sum((P-G).values())} -> {sum((L-G).values())} lost={sum(lost.values())} gained={sum(gained.values())}')
    if os.environ.get('V'):
        for k, v in lost.items(): print('   LOST', v, k[:300])
