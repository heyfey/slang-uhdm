#!/usr/bin/env python3
"""r11u165 map (eighth edition): every table past final8.py (report7.py's shape, rewritten for this base).
 * the decodes MEASURED: f2f2d30b + r11u166's law_on_d48f8f8a8.patch + law_litall.patch + law_macroconn.patch +
   r11u161's law.patch (a 3-way apply whose only conflicts are the helper declarations, both sides kept:
   evidence/decodes_scratch.patch). One binary, its full sweep re-dumped and re-keyed (WS). Pair B r11u164 lands
   r11u161 first and holds the macro model's next faces, so the decodes are pair B's MEASURED share;
 * pair B r11u164's other brief items (OPTIMISTIC: a covered cluster counts fixed whole), routes.json;
 * pair A: r11u163 LANDED as pass 163 (576b21fa) before this base; no live pair-A brief is in this map's hands;
 * the fail list after the decodes (measured) and pair B (optimistic), per corpus/mode and for probe;
 * the ranked OPEN clusters with ground and site; the first clusters; the per-ground greedy sets; structural rows;
   the family view; cluster_index.csv / fail_list.csv / probe_fail_list.csv.
Args: <work W> <law work WS> <out dir> <law sweep dir> <routes.json> <ground_override.json> <repo>"""
import os, sys, json, csv, collections, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import rekey
W, WS, OUT, LSW, ROUTES, GOV, REPO = sys.argv[1:8]
ids = json.load(open(f'{W}/ids.json')); cid = ids['cid']; KEY = ids['key']; M7 = ids['m7']
SITES = json.load(open(f'{W}/sites.json'))
RT = json.load(open(ROUTES)); GOVJ = json.load(open(GOV))
_t = open(os.path.join(REPO, 'RESUME.md')).read()
FEN = set(re.findall(r'`([A-Za-z_][A-Za-z0-9_]*)`', re.search(r'The four slang-fenced tests(.*?)are NEVER dispatched', _t, re.S).group(1)))
assert len(FEN) == 4
red = lambda n: 'FENCED' if n in FEN else n
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
RS, FS, newS, NS = load(f'{WS}/corpus.jsonl', ck, 'NEWL:')
PS, PFS, pnewS, _ = load(f'{WS}/probe.jsonl', lambda r: r['strict'], 'NEWL:')
strict0 = {}; strictS = {}
for c in ('surelog', 'uhdm2rtlil'):
    for r in csv.DictReader(open(f'{W}/sweep_{c}.csv')): strict0[(c, r['mode'], r['name'])] = r['strict']
    for r in csv.DictReader(open(f'{LSW}/{c}.csv')): strictS[(c, r['mode'], r['name'])] = r['strict']
pstrict0 = {r['case']: r['strict'] for r in csv.DictReader(open(f'{W}/sweep_probe.csv'))}
pstrictS = {r['case']: r['strict'] for r in csv.DictReader(open(f'{LSW}/probe.csv'))}
LAWP = {l.split('\t')[0]: l.rstrip('\n').split('\t')[1] for l in open(f'{W}/probe_law.tsv')}
down = {r['name']: r['verdict'] for r in csv.DictReader(open(f'{REPO}/results/downstream_uhdm2rtlil.csv'))}
ALL = set(KEY)
rc0 = collections.defaultdict(set); rcS = collections.defaultdict(set); pr0 = collections.defaultdict(set); prS = collections.defaultdict(set)
for k, s in R0.items():
    for c in s: rc0[c].add(k)
for k, s in RS.items():
    for c in s: rcS[c].add(k)
for k, s in P0.items():
    for c in s: pr0[c].add(k)
for k, s in PS.items():
    for c in s: prS[c].add(k)
# ---------------------------------------------------------------- grounds and sites
GA = ('ExprEmit.cpp', 'EmitHelpers.h', 'StmtEmit.cpp', 'ParamEmit.cpp'); GB = ('TypeEmit.cpp', 'ModuleEmit.cpp', 'UhdmExporter.cpp', 'TaskFuncEmit.cpp', 'uhdm_main.cpp', 'uhdm_main')
def site(c):
    s = SITES.get(c)
    if s: return s
    o = M7.get(c, {}).get('site', '-')
    if o in ('', '-'): return '-'
    return o if re.search(r'\[r11u1\d\dmap pin', o) else o + ' [r11u156map pin]'
def own(c):
    m = re.search(r'\((\w+\.(?:cpp|h))', site(c)) or re.search(r'(uhdm_main)', site(c))
    return m.group(1) if m else '?'
def ground(c):
    if c in GOVJ: return GOVJ[c]
    o = own(c); return 'A' if o in GA else ('B' if o in GB else '?')
# ---------------------------------------------------------------- families
FAM = [('UVM', lambda t: t in ('MiniAmiq', 'SeqDriver', 'SimpleUVM', 'Scoreboard', 'BuildUVMPkg')),
       ('Earlgrey', lambda t: t == 'Earlgrey_0_1'), ('Rggen', lambda t: t == 'Rggen'), ('BlackBePipeInt', lambda t: t == 'BlackBePipeInt'),
       ('Scr1', lambda t: t == 'Scr1SvTests'), ('ibex', lambda t: t.startswith('ibex_')), ('rp32', lambda t: t.startswith('rp32_')),
       ('ApbSlave', lambda t: t == 'ApbSlave')]
def fam(t):
    for n, f in FAM:
        if f(t): return n
    return ''
UE = lambda k: fam(k[2]) in ('UVM', 'Earlgrey')
# ---------------------------------------------------------------- coverage
LAWGONE = {c for c in ALL if (rc0.get(c) or pr0.get(c)) and not rcS.get(c) and not prS.get(c)}
NAMED_ROWS = RT['pairB_rows']            # test -> why
namedrow = lambda k: k[2] in NAMED_ROWS and (NAMED_ROWS[k[2]].get('modes') is None or k[1] in NAMED_ROWS[k[2]]['modes'])
def coverage(c):
    if c in LAWGONE: return 'COVERED r11u164 (decodes r11u161+r11u166, MEASURED: gone under the law binary)'
    if c in RT['pairB']: return f"COVERED r11u164 ({RT['pairB'][c]})"
    rows = rc0.get(c, set())
    if ground(c) == 'B' and rows:
        nm = [k for k in rows if namedrow(k)]
        if len(nm) == len(rows): return 'COVERED r11u164 (row named: ' + ', '.join(sorted({NAMED_ROWS[k[2]]['why'] for k in nm})) + ')'
        if all(UE(k) or namedrow(k) for k in rows) and any(UE(k) for k in rows): return 'COVERED r11u164 (UVM/Earlgrey-only, ground B)'
        if nm: return 'OPEN (one shape named by r11u164: ' + ', '.join(sorted({NAMED_ROWS[k[2]]['why'] for k in nm})) + ')'
    if c in RT['shape']: return f"OPEN (one shape named by {RT['shape'][c]})"
    if c in RT['residue']: return f"OPEN (residue: {RT['residue'][c]})"
    m = M7.get(c)
    if not m: return 'OPEN (new since r11u156map)'
    oc = m['cov_p147']
    if 'r11u152' in oc.split('(')[0] and oc.startswith('COVERED'): return 'OPEN (map 7 gave it to r11u152; pass 152 left it)'
    if 'residue of pass 147' in oc: return 'OPEN (map 7: residue of pass 147; still present)'
    if c in RT['m7listed']: return f"OPEN (map 7 listed it: {RT['m7listed'][c]}; passes 152-163 left it)"
    return 'OPEN'
def coverage2(c):
    s = coverage(c)
    a, b = len(rc0.get(c, ())), len(rcS.get(c, ()))
    pa, pb = len(pr0.get(c, ())), len(prS.get(c, ()))
    if not s.startswith('COVERED') and c in RT['residue'] and 'residue' not in s:
        s += f" [residue: {RT['residue'][c]}]"
    if not s.startswith('COVERED') and (b < a or pb < pa):
        s += f' [the decodes reduce it: rows {a}->{b}, probe {pa}->{pb}]'
    return s
cov = {c: coverage2(c) for c in ALL}
iscov = lambda c: cov[c].startswith('COVERED')
B = {c for c in ALL if iscov(c) and c not in LAWGONE}    # applied optimistically on the law cross-section
yld = lambda S, RR: {k for k, s in RR.items() if s <= S}
def tests(ks, RR):
    t = collections.defaultdict(list)
    for k in RR: t[(k[0], k[2])].append(k in ks)
    return {k for k, v in t.items() if all(v)}
nt = lambda ks: len({(k[0], k[2]) for k in ks})
rk = lambda k: f'{k[0][:3]}/{k[1][0]}/{red(k[2])}'
P = print
P('== 0. fail list at f2f2d30b (the HEAD sweep /tmp/intr11u163 = results/golden_*.csv):', len(R0), 'row-modes /', nt(R0), 'tests; probe', len(P0))
for c_ in ('surelog', 'uhdm2rtlil'):
    for m in ('default', 'testflags'):
        P(f'   {c_} {m}: {sum(1 for k in R0 if k[0] == c_ and k[1] == m)}')
# ---------------------------------------------------------------- 1. decodes measured
conv = set(R0) - set(RS); ent = set(RS) - set(R0); pconv = set(P0) - set(PS); pent = set(PS) - set(P0)
P(f'== 1. the decodes MEASURED (r11u161 law.patch + r11u166 law_on_d48f8f8a8 + litall + macroconn): corpus {len(R0)} -> {len(RS)} ({len(conv)} converted, {len(ent)} entered); probe {len(P0)} -> {len(PS)} ({len(pconv)} converted, {len(pent)} entered)')
P('   converted:', ' '.join(rk(k) for k in sorted(conv)))
P('   probe converted:', ' '.join(sorted(pconv)))
P('   entered:', ' '.join(rk(k) for k in sorted(ent)), '| probe entered:', ' '.join(sorted(pent)))
chg = sorted(k for k in RS if strict0.get(k) != strictS.get(k))
P(f'   corpus rows whose strict cell changed (not converted): {len(chg)}:', '; '.join(f'{rk(k)} {strict0[k]} -> {strictS[k]}' for k in chg))
pchg = sorted(k for k in PS if pstrict0.get(k) != pstrictS.get(k))
P(f'   probe cases whose cell changed: {len(pchg)}:', '; '.join(f'{k} {pstrict0[k]} -> {pstrictS[k]}' for k in pchg))
P(f'   keys new under the law (not in the pristine map): corpus {len(newS)}, probe {len(pnewS)}:', '; '.join(f'{k} x{n}' for k, n in newS.most_common(8)), '|', '; '.join(f'{k} x{n}' for k, n in pnewS.most_common(8)))
P(f'   clusters gone under the law: {len(LAWGONE)}:', ' '.join(sorted(LAWGONE)))
fell = sorted((c for c in ALL if rc0.get(c) and rcS.get(c) and len(rcS[c]) < len(rc0[c])), key=lambda c: -(len(rc0[c]) - len(rcS[c])))
P('   clusters that fell (rows):', ' '.join(f'{c} {len(rc0[c])}->{len(rcS[c])}' for c in fell))
# ---------------------------------------------------------------- 2. pair-B yields
after = {k for k in RS if not RS[k] <= B}
cleared = set(R0) - after
pafter = {k for k in PS if not PS[k] <= B}
cBn = yld(B, R0)
P('== 2. yields (row-modes / tests cleared in every NE mode / probe cases)')
P(f'   the decodes, MEASURED: {len(conv)} / {len(tests(conv, R0))} / {len(pconv)}')
P(f'   pair B r11u164 other items, optimistic ({len(B)} clusters) on the pristine map alone: {len(cBn)} / {len(tests(cBn, R0))} / {len(yld(B, P0))}')
P(f'   both (decodes measured, then pair B optimistic on the law cross-section): {len(cleared)} row-modes / {len(tests(cleared, R0))} tests / {len(P0) - len(pafter)} probe')
T5 = []
for c_ in ('surelog', 'uhdm2rtlil'):
    for m in ('default', 'testflags'):
        s0 = sum(1 for k in R0 if k[0] == c_ and k[1] == m); s1 = sum(1 for k in RS if k[0] == c_ and k[1] == m)
        s2 = sum(1 for k in after if k[0] == c_ and k[1] == m); T5.append((c_, m, s0, s1, s2))
        P(f'   {c_} {m}: today {s0}; after the decodes (measured) {s1}; after pair B too {s2}')
P(f'   FAIL LIST AFTER THE DECODES + PAIR B: {len(after)} row-modes / {nt(after)} tests (today {len(R0)} / {nt(R0)}); probe {len(pafter)} (today {len(P0)})')
P('   rows cleared:', ' '.join(rk(k) + ('[dec]' if k in conv else '[B]') for k in sorted(cleared)))
# ---------------------------------------------------------------- 3. per-cluster columns
def alone(c):
    return sum(1 for k in after if RS[k] <= B | {c})
firstA = collections.Counter(FS[k] for k in after)
P0N = {c: len(pr0.get(c, ())) for c in ALL}
rank = sorted(ALL, key=lambda c: (-len(rc0.get(c, ())), -P0N[c], -ids['objC'].get(c, 0), c))
CI = {}
for i, c in enumerate(rank):
    rs = rc0.get(c, set()); m = M7.get(c, {})
    CI[c] = dict(cluster_id=c, rank=i + 1, rows=len(rs), rows_surelog=sum(1 for k in rs if k[0] == 'surelog'),
                 rows_uhdm2rtlil=sum(1 for k in rs if k[0] == 'uhdm2rtlil'), tests=nt(rs), objects=ids['objC'].get(c, 0),
                 probe_cases=P0N[c], first_in_rows=sum(1 for k in rs if F0.get(k) == c), ground=ground(c), coverage=cov[c],
                 rows_after_law=len(rcS.get(c, ())), probe_after_law=len(prS.get(c, ())),
                 rows_after_pairs=0 if iscov(c) else len([k for k in rcS.get(c, ()) if k in after]),
                 probe_after_pairs=0 if iscov(c) else len([k for k in prS.get(c, ()) if k in pafter]),
                 first_in_after_pairs=firstA.get(c, 0), alone_on_top_of_pairs=0 if iscov(c) or c not in rcS else alone(c),
                 alone_on_pristine=len(yld({c}, R0)),
                 map7_rows_89d599ef=m.get('rows', '-'), map7_rows_p147=m.get('rows_p147', '-'), map7_probe=m.get('probe_cases', '-'),
                 map7_coverage_p147=m.get('cov_p147', 'new'), families=' '.join(sorted({fam(k[2]) for k in rs} - {''})),
                 example_tests=' '.join(sorted({red(k[2]) for k in rs})[:6]), site=site(c), probe_laws=ids['plaws'].get(c, ''),
                 key=KEY[c], example=ids['exs'][KEY[c]] if KEY[c] in ids['exs'] else '')
with open(f'{OUT}/cluster_index.csv', 'w', newline='') as f:
    w = csv.DictWriter(f, list(next(iter(CI.values())).keys())); w.writeheader()
    for c in rank: w.writerow(CI[c])
with open(f'{OUT}/fail_list.csv', 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['corpus', 'test', 'mode', 'strict', 'first_cluster', 'first_cluster_coverage', 'first_ground', 'first_site', 'clusters',
                'open_clusters', 'family', 'downstream', 'strict_after_decodes', 'first_cluster_after_decodes', 'open_clusters_after_pairs',
                'clears_after_decodes_and_pair_b'])
    for k in sorted(R0):
        s = R0[k]; fc = F0[k]
        w.writerow([k[0], red(k[2]), k[1], strict0[k], fc, cov[fc], ground(fc), site(fc), len(s), sum(1 for c in s if not iscov(c)),
                    fam(k[2]), down.get(k[2], '') if k[0] == 'uhdm2rtlil' else '', strictS.get(k, '?') if k in RS else 'equal (decodes, measured)',
                    FS.get(k, '-') if k in RS else '-', ' '.join(sorted(c for c in RS.get(k, set()) if c not in B)),
                    'yes (decodes, measured)' if k in conv else ('yes (pair B, optimistic)' if k not in after else 'no')])
with open(f'{OUT}/probe_fail_list.csv', 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['case', 'law', 'strict', 'first_cluster', 'first_cluster_coverage', 'first_ground', 'first_site', 'clusters', 'open_clusters',
                'strict_after_decodes', 'first_cluster_after_decodes', 'clears_after_decodes_and_pair_b'])
    for k in sorted(P0):
        s = P0[k]; fc = PF0[k]
        w.writerow([k, LAWP.get(k, '-'), pstrict0[k], fc, cov[fc], ground(fc), site(fc), len(s), sum(1 for c in s if not iscov(c)),
                    pstrictS.get(k, '?'), PFS.get(k, '-') if k in PS else '-',
                    'yes (decodes, measured)' if k in pconv else ('yes (pair B, optimistic)' if k not in pafter else 'no')])
json.dump(dict(after=['|'.join(k) for k in after], B=sorted(B), LAWGONE=sorted(LAWGONE), conv=['|'.join(k) for k in conv]), open(f'{W}/report8_state.json', 'w'))
# ---------------------------------------------------------------- 4. ranked OPEN
esc = lambda s: str(s).replace('|', '\\|')
openr = [c for c in rank if not iscov(c) and CI[c]['rows_after_pairs'] > 0]
openr.sort(key=lambda c: (-CI[c]['rows_after_pairs'], -CI[c]['alone_on_top_of_pairs'], -CI[c]['first_in_after_pairs'], -CI[c]['probe_after_law'], c))
P(f'== 4. OPEN clusters with a row after the decodes + pair B: {len(openr)} (ground A {sum(1 for c in openr if CI[c]["ground"] == "A")}, B {sum(1 for c in openr if CI[c]["ground"] == "B")}, ? {sum(1 for c in openr if CI[c]["ground"] == "?")})')
P('| # | cluster | rows left (f2f2d30b) | sl/u2r | tests | heads | alone | probe (after dec) | ground | status | key | site (mint < caller < caller) |')
P('|---|---|---|---|---|---|---|---|---|---|---|---|')
for i, c in enumerate(openr[:70]):
    r = CI[c]
    P(f"| {i+1} | {c} | {r['rows_after_pairs']} ({r['rows']}) | {r['rows_surelog']}/{r['rows_uhdm2rtlil']} | {r['tests']} | {r['first_in_after_pairs']} | {r['alone_on_top_of_pairs']} | {r['probe_after_law']} | {r['ground']} | {esc(r['coverage'][:70])} | `{esc(r['key'])}` | {esc(r['site'][:150])} |")
po = sorted((c for c in ALL if not iscov(c) and not rc0.get(c) and P0N[c]), key=lambda c: -len(prS.get(c, ())))
P('   probe-only OPEN clusters with the most cases (after the decodes):', ' '.join(f"{c} ({len(prS.get(c, ()))}, {ground(c)})" for c in po[:12]))
pl = collections.Counter(); tot = collections.Counter()
for k in P0:
    for law in LAWP.get(k, '-').split(): pl[law] += 1
for k, v in LAWP.items():
    for law in v.split(): tot[law] += 1
P('   laws with the most NE cases:', '; '.join(f'{a} {n}/{tot[a]}' for a, n in pl.most_common(10)))
# ---------------------------------------------------------------- 5. first clusters
P('== 5. first clusters of the rows left after the decodes + pair B')
P('| first cluster | row-modes it heads | ground | status | key | site |')
P('|---|---|---|---|---|---|')
for c, n in firstA.most_common(30):
    P(f"| {c} | {n} | {ground(c)} | {esc(cov.get(c, 'new-under-law')[:60])} | `{esc(KEY.get(c, c))}` | {esc(site(c)[:120]) if c in ALL else '-'} |")
P('   pristine first clusters (f2f2d30b):', ' '.join(f'{c}:{n}' for c, n in collections.Counter(F0.values()).most_common(25)))
P('   pristine probe first clusters:', ' '.join(f'{c}:{n}' for c, n in collections.Counter(PF0.values()).most_common(25)))
# ---------------------------------------------------------------- 6. pair B covered
P('== 6. pair B r11u164 covered clusters (decodes measured + the rest optimistic): rows f2f2d30b -> after the decodes; probe')
P('| cluster | rows f2f2d30b (sl/u2r) | after decodes | probe f2f2d30b -> after decodes | coverage | key |')
P('|---|---|---|---|---|---|')
for c in sorted((c for c in ALL if iscov(c)), key=lambda c: (-len(rc0.get(c, ())), -P0N[c], c)):
    r = CI[c]
    if r['rows'] == 0 and r['probe_cases'] < 3: continue
    P(f"| {c} | {r['rows']} ({r['rows_surelog']}/{r['rows_uhdm2rtlil']}) | {r['rows_after_law']} | {r['probe_cases']} -> {r['probe_after_law']} | {esc(r['coverage'][:90])} | `{esc(r['key'])}` |")
# ---------------------------------------------------------------- 7. structural
P('== 7. structural rows (first field depth / type / count) and probe cases')
for tag, S0, Sx in (('f2f2d30b', strict0, None), ('after the decodes', strictS, None)):
    st = sorted(k for k in (R0 if tag == 'f2f2d30b' else RS) if re.match(r'differ:(depth|type|count|stage1)', S0.get(k, '')))
    P(f'   {tag}: {len(st)} row-modes:', '; '.join(f'{rk(k)} {S0[k]} first={F0[k] if tag == "f2f2d30b" else FS[k]}' for k in st))
pst = collections.Counter(re.match(r'differ:(\w+)', v).group(1) for v in pstrict0.values() if re.match(r'differ:(depth|type|count)', v))
P('   probe structural first fields:', dict(pst))
# ---------------------------------------------------------------- 8. greedy sets per ground
tests_all = collections.defaultdict(list)
for k in R0: tests_all[(k[0], k[2])].append(k)
aopen = {k: {c for c in RS[k] if c not in B} for k in after}
base = len(R0) - len(after)
def clr(S):
    ks = {k for k, s in aopen.items() if s <= S}
    tt = {t for t, ms in tests_all.items() if all((m not in after) or (m in ks) for m in ms)}
    return ks, tt
nopen = collections.Counter(min(len(s), 6) for s in aopen.values())
gmix = collections.Counter(('A' if all(ground(c) == 'A' for c in s if c in ALL) else 'B' if all(ground(c) == 'B' for c in s if c in ALL) else '?' if any((c not in ALL) or ground(c) == '?' for c in s) else 'both') for s in aopen.values())
P(f'== 8. greedy sets per ground on top of the decodes (measured) + pair B (optimistic); base cleared {base} row-modes / {len(tests(set(R0) - after, R0))} tests')
P('   rows left by open-cluster count (6 = 6+):', dict(sorted(nopen.items())), '; by ground:', dict(gmix))
for g in ('A', 'B'):
    allg = {c for s in aopen.values() for c in s if c in ALL and ground(c) == g}
    P(f'   every OPEN cluster of ground {g} ({len(allg)}) clears {len(clr(allg)[0])} row-modes ({base + len(clr(allg)[0])} with the pairs)')
for g in ('A', 'B', 'A+B'):
    cands = {frozenset(s) for s in aopen.values() if 0 < len(s) <= (4 if g != 'A+B' else 6) and all(c in ALL and (ground(c) == g or (g == 'A+B' and ground(c) in 'AB')) for c in s)}
    cum = set(); P(f'## ground {g}: {len(cands)} candidate sets')
    P('| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |')
    P('|---|---|---|---|---|---|---|---|')
    for i in range(30 if g != 'A+B' else 40):
        n0 = len(clr(cum)[0]); best = None
        for s in cands:
            add = s - cum
            if not add: continue
            gain = len(clr(cum | s)[0]) - n0
            sc = (gain / len(add), gain, sum(CI[c]['rows_after_pairs'] for c in add))
            if best is None or sc > best[0]: best = (sc, s, add, gain)
        if best is None or best[3] <= 0: break
        cum |= best[1]; ks, tt = clr(cum)
        newrows = sorted(k for k in ks if not aopen[k] <= cum - best[2])
        add = sorted(best[2])
        P(f"| {i+1} | {' + '.join(add)} | {best[3]} | {base + len(ks)} | {len(tests(set(R0) - after | ks, R0))} | "
          f"{' '.join(red(k[2]) + '/' + k[1][0] + ('/u2r' if k[0] == 'uhdm2rtlil' else '') for k in newrows)} | "
          f"{'; '.join('`' + esc(KEY[c]) + '`' for c in add)} | {esc(site(add[0]))[:150]} |")
    ks, tt = clr(cum)
    P(f'\nground {g}: the {len(cum)} clusters above clear {len(ks)} row-modes on top of the pairs ({base + len(ks)} with them)\n')
# ---------------------------------------------------------------- 9. family view
P('== 9. family view')
P('| family | row-modes / tests | clusters per row at f2f2d30b | open per row after the decodes + pair B | distinct clusters -> open | cleared |')
P('|---|---|---|---|---|---|')
for n, f in FAM:
    ks = [k for k in R0 if f(k[2])]
    if not ks: continue
    c0 = [len(R0[k]) for k in ks]; c1 = [len(aopen.get(k, ())) for k in ks]
    d0 = set().union(*[R0[k] for k in ks]); d1 = set().union(*[aopen.get(k, set()) for k in ks])
    P(f'| {n} | {len(ks)} / {nt(ks)} | {min(c0)}-{max(c0)} | {min(c1)}-{max(c1)} | {len(d0)} -> {len(d1)} | {sum(1 for k in ks if k not in after)} |')
near = sorted(k for k in after if len(aopen[k]) == 1)
P(f'   NEAR rows (one open cluster after the decodes + pair B): {len(near)} row-modes / {nt(near)} tests:', '; '.join(f'{rk(k)} {next(iter(aopen[k]))}' for k in near))
two = sorted(k for k in after if len(aopen[k]) == 2)
P(f'   two open clusters: {len(two)} row-modes:', '; '.join(f"{rk(k)} {'+'.join(sorted(aopen[k]))}" for k in two))
near0 = sorted(k for k in R0 if len(R0[k]) == 1)
P(f'   single-cluster rows at f2f2d30b: {len(near0)} row-modes / {nt(near0)} tests:', '; '.join(f'{rk(k)} {next(iter(R0[k]))}' for k in near0))
