#!/usr/bin/env python3
"""r11u138: the README's tables beyond final.py: pair yields NAMED-only (the
briefs' ids) vs with the residues of passes 130/131, the row-modes and tests the
pairs clear, the fail list after the pairs, OPEN clusters by owner file and by
ground with a greedy per ground (the next briefs), markdown tables.
Args: <work dir> <out dir>"""
import os, sys, json, csv, collections, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import rekey
W, OUT = sys.argv[1:3]
ids = json.load(open(f'{W}/ids.json')); cid = ids['cid']; cov = ids['cov']
CI = {r['cluster_id']: r for r in csv.DictReader(open(f'{OUT}/cluster_index.csv'))}
rows = {}; prow = {}
for l in open(f'{W}/corpus.jsonl'):
    r = json.loads(l); rows[(r['corpus'], r['mode'], r['test'])] = {cid[rekey(x)] for x in r['rows']}
for l in open(f'{W}/probe.jsonl'):
    r = json.loads(l); prow[r['strict']] = {cid[rekey(x)] for x in r['rows']}
covof = {CI[c]['cluster_id']: CI[c]['coverage'] for c in CI}
pairs = lambda s: s.split('(')[0]
A = {c for c, v in covof.items() if v.startswith('COVERED') and 'r11u133' in pairs(v)}
B = {c for c, v in covof.items() if v.startswith('COVERED') and 'r11u134' in pairs(v)}
An = {c for c in A if 'residue' not in covof[c]}; Bn = {c for c in B if 'residue' not in covof[c]}
def yld(S, R=rows): return sorted(k for k, s in R.items() if s <= S)
def tests(ks, R=rows):
    t = collections.defaultdict(list)
    for k, s in R.items(): t[(k[0], k[2])].append(k in ks)
    return sorted(k for k, v in t.items() if all(v))
P = print
P('== pair yields (row-modes / tests / probe cases)')
for tag, S in (('A named', An), ('A +residues', A), ('B named', Bn), ('B +residues', B), ('A+B named', An | Bn), ('A+B +residues', A | B)):
    ks = set(yld(S)); P(f'  {tag}: clusters {len(S)}; row-modes {len(ks)}; tests {len(tests(ks))}; probe {len(yld(S, prow))}')
for c_ in ('surelog', 'uhdm2rtlil'):
    for m in ('default', 'testflags'):
        sub = {k: v for k, v in rows.items() if k[0] == c_ and k[1] == m}
        P(f'  {c_} {m}: NE {len(sub)}; A named {len(yld(An, sub))} +res {len(yld(A, sub))}; B named {len(yld(Bn, sub))} +res {len(yld(B, sub))}; '
          f'A+B named {len(yld(An | Bn, sub))} +res {len(yld(A | B, sub))}; after both (+res) {len(sub) - len(yld(A | B, sub))}')
AB = A | B
cl = set(yld(AB)); P('== row-modes the pairs clear (+residues):', len(cl))
for k in sorted(cl): P('  ', '/'.join(k), 'A' if rows[k] <= A else ('B' if rows[k] <= B else 'A+B'))
P('== tests cleared in every NE mode:', ' '.join(f'{c}/{t}' for c, t in tests(cl)))
P('== probe cases the pairs clear:', len(yld(AB, prow)))
iscov = lambda c: covof[c].startswith('COVERED')
own = lambda c: (re.search(r'\((\w+\.(?:cpp|h))', CI[c]['site']) or re.search(r'(uhdm_main)', CI[c]['site']) or [None, '?'])[1]
GA = ('ExprEmit.cpp', 'EmitHelpers.h', 'StmtEmit.cpp', 'ParamEmit.cpp'); GB = ('TypeEmit.cpp', 'ModuleEmit.cpp', 'UhdmExporter.cpp', 'TaskFuncEmit.cpp', 'uhdm_main.cpp', 'uhdm_main')
def ground(c):
    if covof[c].startswith('OPEN (net binding'): return 'B'
    o = own(c); return 'A' if o in GA else ('B' if o in GB else '?')
opn = [c for c in CI if not iscov(c) and int(CI[c]['rows']) > 0]
P('== OPEN clusters with corpus rows by owner file of the pinned mint (clusters / row-modes touched / pinned this edition)')
bo = collections.defaultdict(list)
for c in opn: bo[own(c)].append(c)
for o, cs in sorted(bo.items(), key=lambda x: -len(set().union(*[{k for k, s in rows.items() if c in s} for c in x[1]]))):
    P(f'  {o}: {len(cs)} / {len(set().union(*[{k for k, s in rows.items() if c in s} for c in cs]))} / {sum(1 for c in cs if "r11u132map pin" not in CI[c]["site"] and CI[c]["site"] != "-")}')
P('== next briefs: greedy OPEN clusters per ground on top of both pairs (+residues); step id cum-rows cum-tests key | site')
for g in ('A', 'B'):
    cum = set(AB); base = len(yld(cum)); P(f'  ground {g} (base {base})')
    cand = [c for c in opn if ground(c) == g]
    for i in range(15):
        if not cand: break
        best = max((c for c in cand if c not in cum), key=lambda c: (len(yld(cum | {c})), int(CI[c]['rows'])), default=None)
        if best is None: break
        cum.add(best); ks = set(yld(cum))
        P(f'   {i+1} {best} {len(ks)} {len(tests(ks))} {CI[best]["key"]} | {CI[best]["site"][:150]}')
    ks = set(yld(AB | set(cand))); P(f'   every OPEN cluster of ground {g}: {len(ks)} row-modes, {len(tests(ks))} tests')
P('== rows after the pairs, by the ground of their open clusters: only-A, only-B, both, unknown')
h = collections.Counter()
for k, s in rows.items():
    gs = {ground(c) for c in s if not iscov(c)}
    if not gs: continue
    h['+'.join(sorted(gs))] += 1
P(' ', dict(h))
def md(c):
    r = CI[c]
    return f"| {r['rank']} | {c} | {r['rows']} {r['rows_surelog']}/{r['rows_uhdm2rtlil']} | {r['tests']} | {r['first_in_rows']} | {r['probe_cases']} | {r['coverage']} | `{r['key'].replace('|', chr(92) + '|')}` | {r['example'][:110]} | {r['site'][:230]} |"
P('== MD top OPEN (corpus rows)')
for c in sorted(opn, key=lambda c: int(CI[c]['rank']))[:45]: P(md(c))
P('== MD covered')
for c in sorted([c for c in CI if iscov(c)], key=lambda c: int(CI[c]['rank'])): P(md(c))
