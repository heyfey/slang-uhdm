#!/usr/bin/env python3
"""r11u150 map (sixth edition): every table past final.py, in one pass.
 * the live pairs: pair A r11u145 = its brief's map-5 ids + routed residues, OPTIMISTIC (a covered cluster counts
   fixed whole); pair B r11u146 = r11u148share's law.patch MEASURED (the share binary's full sweep, its
   STRICT_NOTEQUAL rows re-dumped and re-keyed: WS) + the rest of its brief's ids + routed residues, OPTIMISTIC;
 * the fail list after both pairs (share measured, the rest optimistic), per corpus/mode and for probe;
 * the ranked OPEN clusters on top of both pairs (rows, tests, first-in, probe, alone yield), ground, site;
 * the per-ground greedy briefs; the first clusters; probe cases by law;
 * the prediction audit of map 5 (tools/probe/r11u142map) against passes 140 and 144 (landed since);
 * augmented cluster_index.csv / fail_list.csv / probe_fail_list.csv (share + after-pairs columns, ground).
Args: <work W> <share work WS> <out dir> <share sweep dir> <map5 dir> <ground_override.json>"""
import os, sys, json, csv, collections, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import rekey
W, WS, OUT, SSW, M5, GOV = sys.argv[1:7]
ids = json.load(open(f'{W}/ids.json')); cid = ids['cid']
CIL = list(csv.DictReader(open(f'{OUT}/cluster_index.csv'))); CI = {r['cluster_id']: r for r in CIL}
cov = {c: CI[c]['coverage'] for c in CI}
FEN = set()
_t = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', 'RESUME.md')).read()
FEN = set(re.findall(r'`([A-Za-z_][A-Za-z0-9_]*)`', re.search(r'The four slang-fenced tests(.*?)are NEVER dispatched', _t, re.S).group(1)))
def load(p, keyf, tag):
    R = {}; first = {}; newk = collections.Counter(); nobj = collections.Counter()
    for l in open(p):
        r = json.loads(l); k = keyf(r); s = set(); b = None
        for x in r['rows']:
            c = rekey(x); i = cid.get(c)
            if i is None: i = tag + c; newk[c] += 1
            s.add(i); nobj[(k, i)] += x.get('nobj', 1); pos = x['ia'] if x['ia'] >= 0 else x['ib']
            if b is None or pos < b[0]: b = (pos, i)
        R[k] = s; first[k] = b[1] if b else '-'
    return R, first, newk, nobj
ck = lambda r: (r['corpus'], r['mode'], r['test'])
R0, F0, _, N0 = load(f'{W}/corpus.jsonl', ck, 'NEW:')
P0, PF0, _, _ = load(f'{W}/probe.jsonl', lambda r: r['strict'], 'NEW:')
RS, FS, newS, _ = load(f'{WS}/corpus.jsonl', ck, 'NEWS:')
PS, PFS, pnewS, _ = load(f'{WS}/probe.jsonl', lambda r: r['strict'], 'NEWS:')
strictS = {}
for c in ('surelog', 'uhdm2rtlil'):
    for r in csv.DictReader(open(f'{SSW}/{c}.csv')): strictS[(c, r['mode'], r['name'])] = r['strict']
pstrictS = {r['case']: r['strict'] for r in csv.DictReader(open(f'{SSW}/probe.csv'))}
pairs = lambda s: s.split('(')[0]
A = {c for c in CI if cov[c].startswith('COVERED') and 'r11u145' in pairs(cov[c])}
Bn = {c for c in CI if cov[c].startswith('COVERED') and 'r11u146' in pairs(cov[c]) and 'r11u148share' not in cov[c]}
SH = {c for c in CI if 'r11u148share' in cov[c]}
B = Bn | SH; AB = A | B; ABo = A | Bn          # ABo = what is applied optimistically on the share cross-section
iscov = lambda c: c in ABo   # the share clusters are MEASURED: what they leave is open
yld = lambda S, RR: {k for k, s in RR.items() if s <= S}
def tests(ks, RR):
    t = collections.defaultdict(list)
    for k in RR: t[(k[0], k[2])].append(k in ks)
    return {k for k, v in t.items() if all(v)}
nt = lambda ks: len({(k[0], k[2]) for k in ks})
red = lambda n: 'FENCED_1' if n in FEN else n
rk = lambda k: f'{k[0]}/{k[1]}/{red(k[2])}'
# grounds
GOVJ = json.load(open(GOV))
GA = ('ExprEmit.cpp', 'EmitHelpers.h', 'StmtEmit.cpp', 'ParamEmit.cpp'); GB = ('TypeEmit.cpp', 'ModuleEmit.cpp', 'UhdmExporter.cpp', 'TaskFuncEmit.cpp', 'uhdm_main.cpp', 'uhdm_main')
own = lambda c: (re.search(r'\((\w+\.(?:cpp|h))', CI[c]['site']) or re.search(r'(uhdm_main)', CI[c]['site']) or [None, '?'])[1] if c in CI else '?'
def ground(c):
    if c in GOVJ: return GOVJ[c]
    o = own(c); return 'A' if o in GA else ('B' if o in GB else '?')
P = print
# ---------------------------------------------------------------- 0. totals
P('== 0. fail list at 98aa49db (map pristine):', len(R0), 'row-modes /', nt(R0), 'tests; probe', len(P0))
for c_ in ('surelog', 'uhdm2rtlil'):
    for m in ('default', 'testflags'):
        P(f'   {c_} {m}: {sum(1 for k in R0 if k[0] == c_ and k[1] == m)}')
# ---------------------------------------------------------------- 1. share measured
conv = set(R0) - set(RS); ent = set(RS) - set(R0)
P(f'== 1. r11u148share law.patch MEASURED (full sweep of the share binary): corpus {len(R0)} -> {len(RS)} ({len(conv)} converted, {len(ent)} entered); probe {len(P0)} -> {len(PS)} ({len(set(P0) - set(PS))} converted, {len(set(PS) - set(P0))} entered)')
P('   converted:', ' '.join(rk(k) for k in sorted(conv)))
P('   probe converted:', ' '.join(sorted(set(P0) - set(PS))))
chg = [k for k in RS if R0.get(k) != RS[k]]
P(f'   row-modes whose cluster set moved: {len(chg)}:', '; '.join(f"{rk(k)} -{sorted(R0[k] - RS[k])} +{sorted(RS[k] - R0[k])}" for k in sorted(chg)))
pchg = [k for k in PS if P0.get(k) != PS[k]]
P(f'   probe cases whose cluster set moved: {len(pchg)}:', '; '.join(f"{k} -{sorted(P0[k] - PS[k])} +{sorted(PS[k] - P0[k])}" for k in sorted(pchg)))
P(f'   keys the pristine map lacks in the share records: corpus {len(newS)}, probe {len(pnewS)}', list(newS)[:5], list(pnewS)[:5])
predSH = yld(SH | set(), {k: v for k, v in R0.items()})
P(f'   the share clusters predicted (a cluster fixed whole): {len(predSH)} row-modes:', ' '.join(rk(k) for k in sorted(predSH)),
  f'; measured {len(conv)}; predicted-not-measured {sorted(rk(k) for k in predSH - conv)}; measured-not-predicted {sorted(rk(k) for k in conv - predSH)}')
# ---------------------------------------------------------------- 2. pair yields
cA = yld(A, R0); cBn = yld(Bn, R0); cB0 = yld(B, R0); cAB0 = yld(AB, R0)
after = {k for k in RS if not RS[k] <= ABo}          # share measured, then A + B's rest optimistic
cleared = set(R0) - after
pafter = {k for k in PS if not PS[k] <= ABo}
P('== 2. live-pair yields (row-modes / tests cleared in every NE mode / probe cases)')
P(f'   pair A r11u145 optimistic ({len(A)} clusters): {len(cA)} / {len(tests(cA, R0))} / {len(yld(A, P0))}')
P(f'   pair B r11u146: share MEASURED {len(conv)} / {len(tests(conv, R0))} / {len(set(P0) - set(PS))}; its other named+routed clusters optimistic ({len(Bn)} clusters) {len(cBn)} / {len(tests(cBn, R0))} / {len(yld(Bn, P0))}; B whole on the share cross-section {len(set(R0) - {k for k in RS if not RS[k] <= Bn})}')
P(f'   both: {len(cleared)} row-modes / {len(tests(cleared, R0))} tests / {len(P0) - len(pafter)} probe; (pure-cluster optimistic both, no measurement: {len(cAB0)})')
for c_ in ('surelog', 'uhdm2rtlil'):
    for m in ('default', 'testflags'):
        s0 = sum(1 for k in R0 if k[0] == c_ and k[1] == m); s1 = sum(1 for k in RS if k[0] == c_ and k[1] == m)
        s2 = sum(1 for k in after if k[0] == c_ and k[1] == m)
        P(f'   {c_} {m}: today {s0}; after share (measured) {s1}; after both pairs {s2}')
P(f'   FAIL LIST AFTER BOTH PAIRS: {len(after)} row-modes / {nt(after)} tests (today {len(R0)} / {nt(R0)}); probe {len(pafter)} (today {len(P0)})')
P('   rows cleared by the pairs:', ' '.join(rk(k) + ('[A]' if R0[k] <= A else '[share]' if k in conv else '[B]' if RS.get(k, set()) <= Bn else '[A+B]') for k in sorted(cleared)))
# ---------------------------------------------------------------- 3. per-cluster columns
rc0 = collections.defaultdict(set); rcS = collections.defaultdict(set); prS = collections.defaultdict(set)
for k, s in R0.items():
    for c in s: rc0[c].add(k)
for k, s in RS.items():
    for c in s: rcS[c].add(k)
for k, s in PS.items():
    for c in s: prS[c].add(k)
base = len(set(R0) - after)
def alone(c):   # rows it clears ALONE on top of both pairs (share measured)
    return sum(1 for k in after if RS[k] <= ABo | {c})
firstS = collections.Counter(FS[k] for k in after)
extra = {}
for c in CI:
    extra[c] = dict(ground=ground(c), rows_after_share=len(rcS.get(c, ())), probe_after_share=len(prS.get(c, ())),
                    rows_after_pairs=len([k for k in rcS.get(c, ()) if k in after]) if not iscov(c) else 0,
                    first_in_after_pairs=firstS.get(c, 0), alone_on_top_of_pairs=alone(c) if not iscov(c) and c in rcS else 0)
with open(f'{OUT}/cluster_index.csv', 'w', newline='') as f:
    cols = list(CIL[0].keys()) + list(next(iter(extra.values())).keys())
    w = csv.DictWriter(f, cols); w.writeheader()
    for r in CIL: w.writerow({**r, **extra[r['cluster_id']]})
CI = {r['cluster_id']: {**r, **extra[r['cluster_id']]} for r in CIL}
FL = list(csv.DictReader(open(f'{OUT}/fail_list.csv')))
with open(f'{OUT}/fail_list.csv', 'w', newline='') as f:
    cols = list(FL[0].keys()) + ['strict_after_share', 'first_cluster_after_share', 'open_clusters_after_pairs', 'clears_after_both_pairs']
    w = csv.DictWriter(f, cols); w.writeheader()
    for r in FL:
        k = (r['corpus'], r['mode'], r['test'])
        r['strict_after_share'] = strictS.get(k, '?') if k in RS else 'equal (share, measured)'
        r['first_cluster_after_share'] = FS.get(k, '-') if k in RS else '-'
        r['open_clusters_after_pairs'] = ' '.join(sorted(c for c in RS.get(k, set()) if c not in ABo))
        r['clears_after_both_pairs'] = 'yes (share, measured)' if k in conv else ('yes (optimistic)' if k not in after else 'no')
        w.writerow(r)
PFL = list(csv.DictReader(open(f'{OUT}/probe_fail_list.csv')))
with open(f'{OUT}/probe_fail_list.csv', 'w', newline='') as f:
    cols = list(PFL[0].keys()) + ['first_site', 'strict_after_share', 'first_cluster_after_share', 'clears_after_both_pairs']
    w = csv.DictWriter(f, cols); w.writeheader()
    for r in PFL:
        k = r['case']
        r['first_site'] = CI.get(r['first_cluster'], {}).get('site', '-')
        r['strict_after_share'] = pstrictS.get(k, '?'); r['first_cluster_after_share'] = PFS.get(k, '-') if k in PS else '-'
        r['clears_after_both_pairs'] = 'yes (share, measured)' if k not in PS else ('yes (optimistic)' if k not in pafter else 'no')
        w.writerow(r)
# ---------------------------------------------------------------- 4. ranked OPEN clusters
opn = [c for c in CI if not iscov(c) and c in rcS and any(k in after for k in rcS[c])]
opn.sort(key=lambda c: (-CI[c]['rows_after_pairs'], -CI[c]['alone_on_top_of_pairs'], -len(prS.get(c, ())), c))
esc = lambda s: s.replace('|', '\\|')
P(f'== 4. OPEN clusters on the rows left after both pairs: {len(opn)}')
P('| # | cluster | rows (after pairs) | sl/u2r | tests | first in | alone | probe | ground | coverage | key | example | site |')
P('|---|---|---|---|---|---|---|---|---|---|---|---|---|')
for i, c in enumerate(opn[:70]):
    r = CI[c]; ks = [k for k in rcS[c] if k in after]
    P(f"| {i+1} | {c} | {len(ks)} | {sum(1 for k in ks if k[0]=='surelog')}/{sum(1 for k in ks if k[0]=='uhdm2rtlil')} | {nt(ks)} | {r['first_in_after_pairs']} | {r['alone_on_top_of_pairs']} | {len(prS.get(c, ()))} | {r['ground']} | {r['coverage'][:60]} | `{esc(r['key'])}` | {esc(r['example'])[:100]} | {esc(r['site'])[:260]} |")
P('== 4b. OPEN clusters with probe cases only (top 25 by cases after share)')
po = sorted([c for c in CI if not iscov(c) and c in prS and c not in rcS], key=lambda c: -len(prS[c]))
for c in po[:25]: P(f"   {c} probe {len(prS[c])} ground {CI[c]['ground']} {CI[c]['key']} | {CI[c]['site'][:160]}")
# ---------------------------------------------------------------- 5. first clusters after both pairs
P('== 5. first clusters of the rows left after both pairs (row-modes it heads)')
for c, n in firstS.most_common(30):
    r = CI.get(c, {}); P(f"   {c} {n} ground {r.get('ground','?')} {r.get('coverage','NEW')[:50]} {r.get('key','')} | {r.get('site','')[:150]}")
# ---------------------------------------------------------------- 6. per-ground greedy
P('== 6. per-ground greedy on top of both pairs (share measured + the rest optimistic)')
P('   rows after both pairs by the ground of their open clusters:', dict(collections.Counter('+'.join(sorted({ground(c) for c in RS[k] if c not in ABo})) for k in after)))
for g in ('A', 'B'):
    cum = set(ABo); cand = [c for c in opn if ground(c) == g]
    P(f'   ground {g}: {len(cand)} open clusters; base {len(set(R0) - after)} row-modes / {len(tests(set(R0) - after, R0))} tests cleared by the pairs')
    P('| step | cluster | +row-modes | cum row-modes | cum tests | rows carried | probe | key | site |')
    P('|---|---|---|---|---|---|---|---|---|')
    done = set(R0) - after
    for i in range(20):
        best = max((c for c in cand if c not in cum), key=lambda c: (sum(1 for k in after if RS[k] <= cum | {c}), CI[c]['rows_after_pairs'], len(prS.get(c, ()))), default=None)
        if best is None: break
        cum.add(best); cl = done | {k for k in after if RS[k] <= cum}
        gain = len(cl) - len(done) - sum(1 for k in after if RS[k] <= cum - {best})
        P(f"| {i+1} | {best} | {sum(1 for k in after if RS[k] <= cum) - sum(1 for k in after if RS[k] <= cum - {best})} | {len(cl)} | {len(tests(cl, R0))} | {CI[best]['rows_after_pairs']} | {len(prS.get(best, ()))} | `{esc(CI[best]['key'])}` | {esc(CI[best]['site'])[:200]} |")
    allg = done | {k for k in after if RS[k] <= ABo | set(cand)}
    P(f'   every OPEN cluster of ground {g}: {len(allg)} row-modes, {len(tests(allg, R0))} tests cleared (cumulative with the pairs)')
allo = set(R0) - {k for k in after if not RS[k] <= ABo | set(opn)}
P(f'   every OPEN cluster of both grounds: {len(allo)} row-modes')
# ---------------------------------------------------------------- 7. probe by law
LAW = {}
for l in open(f'{W}/probe_law.tsv'):
    k, v = l.rstrip('\n').split('\t'); LAW[k] = v
pl = collections.Counter(); tot = collections.Counter()
for k in P0:
    for law in LAW.get(k, '-').split(): pl[law] += 1
for k, v in LAW.items():
    for law in v.split(): tot[law] += 1
P('== 7. probe: laws with the most strict-NE cases (top 15)')
P('  ', ', '.join(f'{a} {n}/{tot[a]}' for a, n in pl.most_common(15)))
P('   probe-heavy clusters:', ', '.join(f"{c} ({len(prS.get(c, ()))}{', COVERED' if iscov(c) else ''})" for c in sorted(prS, key=lambda c: -len(prS[c]))[:15]))
# ---------------------------------------------------------------- 8. prediction audit of map 5
M5C = {r['cluster_id']: r for r in csv.DictReader(open(f'{M5}/cluster_index.csv'))}
M5F = {(r['corpus'], r['mode'], r['test']): r for r in csv.DictReader(open(f'{M5}/fail_list.csv'))}
M5CL = collections.defaultdict(set)
for r in csv.DictReader(open(f'{M5}/clusters.csv')): M5CL[(r['corpus'], r['mode'], r['test'])].add(r['cluster_id'])
p137 = {k for k, r in M5F.items() if not r['strict_after_p137'].startswith('equal')}
now = {(k[0], k[1], red(k[2])) for k in R0}
left = sorted(p137 - now)
P(f'== 8. prediction audit: map 5 after pass 137 {len(p137)} row-modes -> 98aa49db {len(now)} ({len(left)} left, {len(now - p137)} entered)')
P140 = {('surelog', m, t) for t, ms in (('ClassVar', 'dt'), ('ComplexExprSize', 'dt'), ('DefaultPatternModule', 'dt'), ('IntegerConcat', 'dt'), ('Kmac', 'dt'),
        ('ParamArrayUnsizedPattern', 'dt'), ('ParamFromPackage', 'dt'), ('ParamScope', 'dt')) for m in (['default', 'testflags'] if ms == 'dt' else [])}
P140 |= {('uhdm2rtlil', m, t) for t in ('func_local_compound_xor', 'param_struct_field_bitsel', 'param_unpacked_struct_array', 'struct_dynamic_range', 'struct_member_trailing_index') for m in ('default', 'testflags')}
pred140 = {k for k, r in M5F.items() if r['clears_after_both_pairs_p137'] == 'yes (optimistic)'}
for tag, S in (('pass 140', {k for k in left if k in P140}), ('pass 144', {k for k in left if k not in P140})):
    P(f'   {tag}: {len(S)} row-modes; map 5 predicted (optimistic, pair A) {len(S & pred140)}; unpredicted {len(S - pred140)}')
    for k in sorted(S):
        cl = sorted(M5CL[k]); P(f"     {k[0]}/{k[1]}/{k[2]} map5-first={M5F[k]['first_cluster_after_p137']} predicted={'yes' if k in pred140 else 'no'} map5-clusters={' '.join(c + ('*' if M5C.get(c, {}).get('coverage', '').startswith('COVERED') else '') for c in cl)}")
P(f'   map 5 pair-A prediction: {len(pred140)} row-modes, moved {len(pred140 & set(left))}, not moved {sorted(pred140 - set(left))}')
# cluster-level audit: map 5's covered clusters (pairs r11u140 = pass 140, r11u137 = pass 137) and its section-7 greedy
# lists (the next briefs: ground A -> r11u145's base c24699f1 = pass 140; ground B -> pass 144's brief)
txt = open(f'{M5}/README.md').read(); sec = txt[txt.index('## 7.'):txt.index('## 8.')]
gA = re.findall(r'^\| \d+ \| (N\d{4}) ', sec[:sec.index('**Ground B**')], re.M); gB = re.findall(r'^\| \d+ \| (N\d{4}) ', sec[sec.index('**Ground B**'):], re.M)
nowrows = lambda c: len(rc0.get(c, ()))
m5 = lambda c: M5C.get(c, {}).get('rows_after_p137', '-')
for tag, L in (('map 5 pair A (r11u140 = pass 140) covered', sorted(c for c, r in M5C.items() if r['coverage'].startswith('COVERED r11u140'))),
               ('map 5 section 7 ground A greedy', gA), ('map 5 section 7 ground B greedy', gB)):
    gone = [c for c in L if nowrows(c) == 0]; fell = [c for c in L if 0 < nowrows(c) < int(m5(c) or 0)]; same = [c for c in L if nowrows(c) and nowrows(c) >= int(m5(c) or 0)]
    P(f'   {tag}: {len(L)} clusters; cleared {len(gone)} ({" ".join(gone)}); fell {len(fell)} ({" ".join(f"{c} {m5(c)}->{nowrows(c)}" for c in fell)}); unchanged/grew {len(same)} ({" ".join(f"{c} {m5(c)}->{nowrows(c)}" for c in same)})')
# ---------------------------------------------------------------- 9. markdown: covered clusters, first clusters (at 98aa49db)
P('== 9. MD covered clusters (both live pairs)')
P('| cluster | rows sl/u2r | tests | first in | probe | after share (probe) | coverage | key | site |')
P('|---|---|---|---|---|---|---|---|---|')
for c in sorted([c for c in CI if c in AB], key=lambda c: (-int(CI[c]['rows']), -int(CI[c]['probe_cases']), c)):
    r = CI[c]
    P(f"| {c} | {r['rows']} {r['rows_surelog']}/{r['rows_uhdm2rtlil']} | {r['tests']} | {r['first_in_rows']} | {r['probe_cases']} | {r['rows_after_share']} ({r['probe_after_share']}) | {esc(r['coverage'])[:90]} | `{esc(r['key'])}` | {esc(r['site'])[:200]} |")
P('== 10. MD first clusters at 98aa49db (row-modes each heads)')
P('| first cluster | row-modes it heads | after share | after both pairs | ground | coverage | key | site |')
P('|---|---|---|---|---|---|---|---|')
f0 = collections.Counter(F0.values()); fS = collections.Counter(FS.values())
for c, n in f0.most_common(30):
    r = CI[c]; P(f"| {c} | {n} | {fS.get(c, 0)} | {firstS.get(c, 0) if not iscov(c) else 0} | {r['ground']} | {esc(r['coverage'])[:60]} | `{esc(r['key'])}` | {esc(r['site'])[:180]} |")
