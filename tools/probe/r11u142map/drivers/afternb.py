#!/usr/bin/env python3
"""r11u142: the fail list MEASURED after the net-binding law (a7bee711 + tools/probe/r11u139netbind/law.patch,
the binary slang-uhdm.nb, its full sweep), then the other live-pair clusters applied OPTIMISTICALLY on top
(a covered cluster counts as fixed whole; the net-binding clusters are not re-applied, the sweep measured
them). Same analyzer and key as the pristine map; a key the pristine map lacks is NEW-NB.
Also: the structural rows after net binding, and the per-ground greedy briefs on the after-nb rows.
Args: <pristine work> <nb work> <map out dir> <nb sweep dir>"""
import os, sys, json, csv, collections, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import rekey
W, WN, OUT, NSW = sys.argv[1:5]
TAG = os.environ.get('AFTER_TAG', 'nb')   # 'nb' (a7bee711 + law.patch) or 'p137' (6ef15be0: pass 137 landed = pair B measured)
ids = json.load(open(f'{W}/ids.json')); cid = ids['cid']
CI = {r['cluster_id']: r for r in csv.DictReader(open(f'{OUT}/cluster_index.csv'))}
def load(p, keyf):
    R = {}; first = {}; newk = collections.Counter()
    for l in open(p):
        r = json.loads(l); k = keyf(r); s = set(); b = None
        for x in r['rows']:
            c = rekey(x); i = cid.get(c)
            if i is None: i = 'NEWNB:' + c; newk[c] += 1
            s.add(i); pos = x['ia'] if x['ia'] >= 0 else x['ib']
            if b is None or pos < b[0]: b = (pos, i)
        R[k] = s; first[k] = b[1] if b else '-'
    return R, first, newk
rows0 = {}
for l in open(f'{W}/corpus.jsonl'):
    r = json.loads(l); rows0[(r['corpus'], r['mode'], r['test'])] = {cid[rekey(x)] for x in r['rows']}
prow0 = {}
for l in open(f'{W}/probe.jsonl'):
    r = json.loads(l); prow0[r['strict']] = {cid[rekey(x)] for x in r['rows']}
R, first, newk = load(f'{WN}/corpus.jsonl', lambda r: (r['corpus'], r['mode'], r['test']))
PR, pfirst, pnewk = load(f'{WN}/probe.jsonl', lambda r: r['strict'])
strictN = {}
for c in ('surelog', 'uhdm2rtlil'):
    for r in csv.DictReader(open(f'{NSW}/{c}.csv')): strictN[(c, r['mode'], r['name'])] = r['strict']
cov = {c: CI[c]['coverage'] for c in CI}
isA = lambda c: cov.get(c, '').startswith('COVERED') and 'r11u140' in cov[c].split('(')[0]
isB = lambda c: cov.get(c, '').startswith('COVERED') and 'r11u137' in cov[c].split('(')[0] and 'net binding' not in cov[c]
A = {c for c in CI if isA(c)}; B = {c for c in CI if isB(c)} if TAG == 'nb' else set(); AB = A | B   # p137: pair B has landed (measured)
yld = lambda S, RR: {k for k, s in RR.items() if s <= S}
def tests(ks, RR):
    t = collections.defaultdict(list)
    for k in RR: t[(k[0], k[2])].append(k in ks)
    return {k for k, v in t.items() if all(v)}
P = print
conv = set(rows0) - set(R)
P(f'== [{TAG}] MEASURED (the {TAG} sweep): corpus {len(rows0)} -> {len(R)} row-modes ({len(conv)} converted, 0 entered: {len(set(R) - set(rows0))}); probe {len(prow0)} -> {len(PR)}')
P('   converted:', ' '.join('/'.join(k) for k in sorted(conv)))
P(f'   keys the pristine map lacks, in the after-nb records: corpus {len(newk)} ({sum(newk.values())} facets), probe {len(pnewk)}')
for c, n in newk.most_common(10): P('     NEW-NB', n, c)
chg = [k for k in R if strictN[k] != (CI and '')]
cA = yld(A, R); cB = yld(B, R); cAB = yld(AB, R)
pA = yld(A, PR); pB = yld(B, PR); pAB = yld(AB, PR)
P('== then the other covered clusters, optimistic: A (r11u140, +residues) / B (r11u137 minus net binding) / A+B')
P(f'   corpus row-modes: A {len(cA)}  B {len(cB)}  A+B {len(cAB)}; tests (every NE mode) A+B {len(tests(cAB, R))}; probe A {len(pA)} B {len(pB)} A+B {len(pAB)}')
for cc in ('surelog', 'uhdm2rtlil'):
    for m in ('default', 'testflags'):
        s0 = sum(1 for k in rows0 if k[0] == cc and k[1] == m); s1 = sum(1 for k in R if k[0] == cc and k[1] == m)
        s2 = sum(1 for k in R if k[0] == cc and k[1] == m and k not in cAB)
        P(f'   {cc} {m}: today {s0}; after net binding (measured) {s1}; after both pairs {s2}')
fin = {k for k in R if k not in cAB}; pfin = {k for k in PR if k not in pAB}
nt = lambda ks: len({(k[0], k[2]) for k in ks})
P(f'   FAIL LIST AFTER BOTH PAIRS: {len(fin)} row-modes / {nt(fin)} tests (today {len(rows0)} / {nt(rows0)}); probe {len(pfin)} (today {len(prow0)})')
P('   A+B clears (optimistic):', ' '.join('/'.join(k) for k in sorted(cAB)))
# structural rows after net binding
ff = lambda s: s.split(':', 1)[1].split('(')[0] if s.startswith('differ:') else s
st = sorted(k for k in R if ff(strictN[k]) in ('depth', 'type', 'count'))
P(f'== structural row-modes after net binding (measured): {len(st)} ({nt(st)} tests)')
for k in st:
    f = first[k]; P(f"   {'/'.join(k)}  {strictN[k]}  first={f}  {cov.get(f, 'NEW-NB')[:70]}  key={CI[f]['key'] if f in CI else f}  clears-with-pairs={'yes' if k in cAB else 'no'}")
# per-ground greedy on the after-nb rows
own = lambda c: (re.search(r'\((\w+\.(?:cpp|h))', CI[c]['site']) or re.search(r'(uhdm_main)', CI[c]['site']) or [None, '?'])[1] if c in CI else '?'
GA = ('ExprEmit.cpp', 'EmitHelpers.h', 'StmtEmit.cpp', 'ParamEmit.cpp'); GB = ('TypeEmit.cpp', 'ModuleEmit.cpp', 'UhdmExporter.cpp', 'TaskFuncEmit.cpp', 'uhdm_main.cpp', 'uhdm_main')
DEC = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'evidence', 'ground_override.json'))) if os.path.exists(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'evidence', 'ground_override.json')) else {}
def ground(c):
    if c in DEC: return DEC[c]
    if 'net-binding' in cov.get(c, '') or 'net binding' in cov.get(c, ''): return 'B'
    o = own(c); return 'A' if o in GA else ('B' if o in GB else '?')
# open = every cluster still on a measured row that the optimistic covered set does not claim (in p137 mode pair B's
# named clusters that pass 137 left on a row are open again; in nb mode so are the net-binding clusters the law left)
opn = sorted({c for s in R.values() for c in s if c not in AB})
rc = collections.defaultdict(set)
for k, s in R.items():
    for c in s: rc[c].add(k)
fc = collections.Counter(first.values())
P(f'== OPEN clusters after {TAG} (not in the optimistic covered set), ranked by after-{TAG} row-modes: id rows tests first alone-on-top-of-pairs probe ground coverage key')
base = len(cAB)
for c in sorted(opn, key=lambda c: (-len(rc[c]), c))[:60]:
    P(f"   {c} {len(rc[c])} {nt(rc[c])} {fc.get(c, 0)} {len(yld(AB | {c}, R)) - base} {sum(1 for s in PR.values() if c in s)} {ground(c)} {cov.get(c, 'NEW-NB')[:60]} {CI[c]['key'] if c in CI else ''}")
json.dump({'tag': TAG, 'rows_after_nb': {'/'.join(k): sorted(s) for k, s in R.items()}, 'first_after_nb': {'/'.join(k): v for k, v in first.items()},
           'probe_after_nb': {k: sorted(s) for k, s in PR.items()}, 'probe_first_after_nb': pfirst}, open(f'{WN}/afternb.json', 'w'))
# per-cluster columns (after nb) and per-row columns, merged into cluster_index.csv / fail_list.csv
alone = {c: len(yld(AB | {c}, R)) - base for c in rc}
def merge(path, keyf, cols, vals):
    L = list(csv.reader(open(path))); h = L[0]
    for c in cols:
        if c in h: raise SystemExit(f'{path} already has {c}')
    with open(path, 'w', newline='') as f:
        w = csv.writer(f); w.writerow(h + cols)
        for r in L[1:]: w.writerow(r + vals(dict(zip(h, r))))
sfx = '' if TAG == 'nb' else '_' + TAG
merge(f'{OUT}/cluster_index.csv', None, [x.replace('_after_nb', '_after_' + TAG) for x in ['rows_after_nb', 'tests_after_nb', 'first_in_after_nb', 'alone_on_top_of_pairs_after_nb', 'probe_after_nb']] + (['ground'] if TAG == 'nb' else []),
      lambda r: [len(rc.get(r['cluster_id'], ())), nt(rc.get(r['cluster_id'], ())), fc.get(r['cluster_id'], 0), alone.get(r['cluster_id'], 0),
                 sum(1 for s in PR.values() if r['cluster_id'] in s)] + ([ground(r['cluster_id'])] if TAG == 'nb' else []))
def rowv(r):
    k = (r['corpus'], r['mode'], r['test'])
    if k not in R: return [f'equal ({TAG})', '-', 'yes (measured)']
    return [strictN[k], first[k], 'yes (optimistic)' if k in cAB else 'no']
merge(f'{OUT}/fail_list.csv', None, [f'strict_after_{TAG}', f'first_cluster_after_{TAG}', 'clears_after_both_pairs' + sfx], rowv)
def prowv(r):
    k = r['case'].replace('/cases/', '/cases/')
    if k not in PR: return ['-', 'yes (measured)']
    return [pfirst[k], 'yes (optimistic)' if k in pAB else 'no']
merge(f'{OUT}/probe_fail_list.csv', None, [f'first_cluster_after_{TAG}', 'clears_after_both_pairs' + sfx], prowv)
P(f'== next briefs: greedy OPEN clusters per ground on top of the covered set, on the after-{TAG} rows (measured); step id +rows cum-rows cum-tests probe key | site')
for g in ('A', 'B'):
    cum = set(AB); P(f'  ground {g} (base {base} row-modes / {len(tests(cAB, R))} tests cleared by the pairs)')
    cand = [c for c in opn if ground(c) == g]
    prev = base
    for i in range(20):
        best = max((c for c in cand if c not in cum), key=lambda c: (len(yld(cum | {c}, R)), len(rc[c]), c), default=None)
        if best is None: break
        cum.add(best); ks = yld(cum, R)
        P(f"   {i+1} {best} +{len(ks) - prev} {len(ks)} {len(tests(ks, R))} {sum(1 for s in PR.values() if best in s)} {CI[best]['key'] if best in CI else best} | {CI[best]['site'][:170] if best in CI else ''}")
        prev = len(ks)
    ks = yld(AB | set(cand), R); P(f'   every OPEN cluster of ground {g}: {len(ks)} row-modes, {len(tests(ks, R))} tests')
ks = yld(AB | set(opn), R); P(f'  every OPEN cluster of both grounds: {len(ks)} row-modes')
h = collections.Counter()
for k, s in R.items():
    gs = {ground(c) for c in s if c not in AB}
    if gs: h['+'.join(sorted(gs))] += 1
P(f'== after-{TAG} rows by the ground of their open clusters:', dict(h), 'rows with no open cluster (cleared by the covered set):', sum(1 for s in R.values() if s <= AB))
