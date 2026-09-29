#!/usr/bin/env python3
"""r11u230 map (fifteenth edition, base 97343175): every table past final15.py (map 14's report14b.py re-based).
The map is read at HEAD (the 97343175 integration sweep, /tmp/intr11u229 when measured) and the live pairs are counted
OPTIMISTICALLY on it (a covered cluster counts fixed whole): pair A r11u227 (ExprEmit/EmitHelpers/StmtEmit/ParamEmit,
base ac0dda58) and pair B r11u228 (TypeEmit/ModuleEmit/UhdmExporter/TaskFuncEmit/uhdm_main, base 1a30095a), their brief
items mapped to clusters and rows in routes.json (drivers/mkroutes15.py); pair A also takes the UVM ground-A families
and the Earlgrey ground-A scope-name family, pair B the ground-B clusters of the UVM/Earlgrey rows' first ten differing
records (map 11's rule); the NAMED subset (pairX_named) gives the non-optimistic count beside it. A cluster's ground is
map 14's decoded override (ground_override.json), else the file of the WRITER of its differing field (this edition's
writer pins, sites_writer.json, drivers/pinwriter.py + pwsum.py), else the file of its mint (the site pin).
Args: <work W> <out dir> <HEAD sweep dir> <routes.json> <ground_override.json> <repo>
M8 below is the PREVIOUS map (map 14, tools/probe/r11u222map); the name is kept from report9.py."""
import os, sys, json, csv, collections, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import rekey, fenced
W, OUT, LSW, ROUTES, GOV, REPO = sys.argv[1:7]; WS = W   # no law patch: the 'law' view IS the HEAD view
BL = os.environ.get('MAP_BASE_LABEL', '97343175')   # the commit the analysis reads (the addendum sets it)
ids = json.load(open(f'{W}/ids.json')); cid = ids['cid']; KEY = ids['key']; M8 = ids['m8']
# a key that exists only under the law patch gets the next free id above every id maps 3-13 used
_used = set(cid.values()) | {'N2470'}
for _m in ('r11u132map', 'r11u138map', 'r11u142map', 'r11u150map', 'r11u156map', 'r11u165map', 'r11u179map', 'r11u189map', 'r11u197map', 'r11u203map', 'r11u211map', 'r11u222map'):
    for _r in csv.DictReader(open(f'{REPO}/tools/probe/{_m}/cluster_index.csv')): _used.add(_r['cluster_id'])
_nx = [int(max(u for u in _used if u.startswith('N'))[1:]) + 1]
LAWNEW = {}
def lawnew(c):
    if c not in cid:
        cid[c] = 'N%04d' % _nx[0]; _nx[0] += 1; KEY[cid[c]] = c; LAWNEW[cid[c]] = c
    return cid[c]
SITES = json.load(open(f'{W}/sites.json')) if os.path.exists(f'{W}/sites.json') else {}
WRITERS = json.load(open(f'{W}/sites_writer.json')) if os.path.exists(f'{W}/sites_writer.json') else {}
RT = json.load(open(ROUTES)); GOVJ = json.load(open(GOV))
TAGS = RT.get('tags', {'pairA': 'r11u227', 'pairB': 'r11u228'})
FEN = fenced(); red = lambda n: 'FENCED' if n in FEN else n
ORDER = {}
def load(p, keyf, tag):
    R = {}; first = {}; newk = collections.Counter(); first10 = {}
    for l in open(p):
        r = json.loads(l); k = keyf(r); s = set(); b = None; pos = []
        for x in r['rows']:
            c = rekey(x); i = cid.get(c)
            if i is None:
                newk[c] += 1
                i = lawnew(c) if tag == 'NEWL:' else tag + c
            s.add(i); q = x['ia'] if x['ia'] >= 0 else x['ib']; pos.append((q, i))
            if b is None or q < b[0]: b = (q, i)
        R[k] = s; first[k] = b[1] if b else '-'
        seen = [];
        for q, i in sorted(pos):
            if q not in [z[0] for z in seen]: seen.append((q, i))
            if len(seen) >= 10: break
        first10[k] = {i for _, i in seen}
        ORDER[(tag, k)] = [i for _, i in sorted(pos)]
    return R, first, newk, first10
ck = lambda r: (r['corpus'], r['mode'], r['test'])
R0, F0, _, T0 = load(f'{W}/corpus.jsonl', ck, 'NEW:')
P0, PF0, _, _ = load(f'{W}/probe.jsonl', lambda r: r['strict'], 'NEW:')
RS, FS, newS, TS = load(f'{WS}/corpus.jsonl', ck, 'NEWL:')
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
def inv(RR):
    d = collections.defaultdict(set)
    for k, s in RR.items():
        for c in s: d[c].add(k)
    return d
rc0, rcS, pr0, prS = inv(R0), inv(RS), inv(P0), inv(PS)
# ---------------------------------------------------------------- grounds and sites
GA = ('ExprEmit.cpp', 'EmitHelpers.h', 'StmtEmit.cpp', 'ParamEmit.cpp'); GB = ('TypeEmit.cpp', 'ModuleEmit.cpp', 'UhdmExporter.cpp', 'TaskFuncEmit.cpp', 'uhdm_main.cpp', 'uhdm_main')
def site(c):
    s = SITES.get(c)
    if isinstance(s, dict): s = s['site'] + ' [r11u230 pin]'
    if s: return s
    o = M8.get(c, {}).get('site', '-')
    if o in ('', '-'): return '-'
    return o if re.search(r'\[r11u[12]\d\d(map)? pin', o) else o + ' [r11u222map pin]'
def writer(c):
    w = WRITERS.get(c)
    return w['writer'] if w else '-'
def own(c):
    m = re.search(r'\((\w+\.(?:cpp|h))', site(c)) or re.search(r'(uhdm_main)', site(c))
    return m.group(1) if m else '?'
def gof(o): return 'A' if o in GA else ('B' if o in GB else '?')
def ground(c):
    # r11u230: a pass's DECODE (map 14's ground_override.json) decides first: the audit of pass 225's two conversions
    # (README section 10) shows the writer frame of N0191 / N0427 in ExprEmit emitExpr while the law landed in the
    # ground-B caller the decode named; then the WRITER of the differing field; then the mint
    if c in GOVJ: return GOVJ[c]
    w = WRITERS.get(c)
    if w and gof(w.get('owner', '?')) != '?': return gof(w['owner'])
    return gof(own(c))
def chain_grounds(c):
    w = WRITERS.get(c)
    if not w: return '-'
    fs = re.findall(r'\((\w+\.(?:cpp|h))', w['writer'])
    return '+'.join(sorted({gof(f) for f in fs} - {'?'})) or '?'
# ---------------------------------------------------------------- families
FAM = [('UVM', lambda t: t in ('MiniAmiq', 'SeqDriver', 'SimpleUVM', 'Scoreboard', 'BuildUVMPkg')),
       ('Earlgrey', lambda t: t == 'Earlgrey_0_1'), ('Rggen', lambda t: t == 'Rggen'), ('BlackBePipeInt', lambda t: t == 'BlackBePipeInt'),
       ('Scr1', lambda t: t == 'Scr1SvTests'), ('ibex', lambda t: t.startswith('ibex_')), ('rp32', lambda t: t.startswith('rp32_')),
       ('jeras', lambda t: t.startswith('jeras_')), ('ApbSlave', lambda t: t == 'ApbSlave'), ('SVSwitch', lambda t: t == 'SVSwitch'),
       ('FuncStructVal', lambda t: t == 'FuncStructVal'), ('struct_param_func_config', lambda t: t == 'struct_param_func_config'),
       ('cfg_func_width_loop', lambda t: t == 'cfg_func_width_loop'), ('the harness rows (InterfaceModPort, PreprocTest)', lambda t: t in ('InterfaceModPort', 'PreprocTest')),
       ('LogicTypespec', lambda t: t == 'LogicTypespec')]
def fam(t):
    for n, f in FAM:
        if f(t): return n
    return ''
UE = lambda k: fam(k[2]) in ('UVM', 'Earlgrey')
# ---------------------------------------------------------------- map 14's lists (section 8 of its report)
M8L = {}; cur = None
for l in open(f'{REPO}/tools/probe/r11u222map/evidence/report.txt'):
    m = re.match(r'## ground (\S+):', l)
    if m: cur = m.group(1); continue
    m = re.match(r'\| (\d+) \| ([N0-9 +]+) \|', l)
    if m and cur:
        for c in m.group(2).split('+'): M8L.setdefault(c.strip(), f'ground-{cur} step {m.group(1)}')
# ---------------------------------------------------------------- coverage
LAWGONE = {c for c in ALL if (rc0.get(c) or pr0.get(c)) and not rcS.get(c) and not prS.get(c)}
FIRST10B = {c for k in RS if UE(k) for c in TS.get(k, set()) if c in ALL and ground(c) == 'B'}
def namedrow(k, pair):
    NR = RT[pair + '_rows']
    return k[2] in NR and (NR[k[2]].get('modes') is None or k[1] in NR[k[2]]['modes'])
def pcover(c, pair, g):
    """(covered?, text) of one pair on cluster c."""
    tag = TAGS[pair]
    if c in RT[pair]: return True, f"COVERED {tag} ({RT[pair][c]})"
    rows = rc0.get(c, set())
    if ground(c) == g and rows:
        nm = [k for k in rows if namedrow(k, pair)]
        if len(nm) == len(rows): return True, f"COVERED {tag} (row named: " + ', '.join(sorted({RT[pair + '_rows'][k[2]]['why'] for k in nm})) + ')'
        if pair == 'pairB' and c in FIRST10B and all(UE(k) or namedrow(k, pair) for k in rows):
            return True, f"COVERED {tag} (a UVM/Earlgrey first record, ground B)"
        if nm and not (pair == 'pairA' and RT.get('uvm_A_families') and all(fam(k[2]) == 'UVM' or namedrow(k, pair) for k in rows)): return False, f"OPEN (one shape named by {tag}: " + ', '.join(sorted({RT[pair + '_rows'][k[2]]['why'] for k in nm})) + ')'
    if pair == 'pairB' and c in FIRST10B and all(UE(k) for k in rows) and rows:
        return True, f"COVERED {tag} (a UVM/Earlgrey first record, ground B)"
    if pair == 'pairA' and RT.get('earl_A_family') and ground(c) == 'A' and rows and all(fam(k[2]) == 'Earlgrey' for k in rows):
        return True, f"COVERED {tag} (the Earlgrey_0_1 ground-A scope-name family, optimistic)"
    if pair == 'pairA' and RT.get('uvm_A_families') and ground(c) == 'A' and rows and all(fam(k[2]) == 'UVM' or namedrow(k, pair) for k in rows):
        return True, f"COVERED {tag} (the UVM ground-A families" + (" and the joint rows' A halves" if not all(fam(k[2]) == 'UVM' for k in rows) else '') + ", optimistic)"
    return False, ''
def coverage(c):
    if c in LAWGONE: return 'COVERED (gone)'
    a, ta = pcover(c, 'pairA', 'A'); b, tb = pcover(c, 'pairB', 'B')
    if a: return ta
    if b: return tb
    if ta: return ta
    if tb: return tb
    m = M8.get(c)
    if not m: return 'OPEN (new since r11u222map)'
    oc = m['coverage']
    if oc.startswith('COVERED r11u224'): return 'OPEN (map 14 gave it to pair A r11u224; pass 224 left it)'
    if oc.startswith('COVERED r11u223'): return 'OPEN (map 14 gave it to pair B r11u223; passes 223 and 225 left it)'
    if c in M8L: return f'OPEN (map 14 listed it: {M8L[c]}; passes 223-225 left it)'
    return 'OPEN'
def coverage2(c):
    s = coverage(c)
    a, b = len(rc0.get(c, ())), len(rcS.get(c, ()))
    pa, pb = len(pr0.get(c, ())), len(prS.get(c, ()))
    if not s.startswith('COVERED') and (b < a or pb < pa):
        s += f' [reduced: rows {a}->{b}, probe {pa}->{pb}]'
    return s
cov = {c: coverage2(c) for c in ALL}
iscov = lambda c: cov[c].startswith('COVERED')
covA = {c for c in ALL if cov[c].startswith('COVERED ' + TAGS['pairA'])}
covB = {c for c in ALL if cov[c].startswith('COVERED ' + TAGS['pairB'])}
# the NAMED subset: only the clusters a brief item names by its decoded head (no row-level, family or first-ten credit)
namA = {c for c in RT.get('pairA_named', {}) if c in ALL} - LAWGONE
namB = {c for c in RT.get('pairB_named', {}) if c in ALL} - LAWGONE
BOTH = covA | covB
yld = lambda S, RR: {k for k, s in RR.items() if s <= S}
def tests(ks, RR):
    t = collections.defaultdict(list)
    for k in RR: t[(k[0], k[2])].append(k in ks)
    return {k for k, v in t.items() if all(v)}
nt = lambda ks: len({(k[0], k[2]) for k in ks})
rk = lambda k: f'{k[0][:3]}/{k[1][0]}/{red(k[2])}'
P = print
P(f'== 0. fail list at {BL} (the HEAD sweep = results/golden_*.csv):', len(R0), 'row-modes /', nt(R0), 'tests; probe', len(P0))
for c_ in ('surelog', 'uhdm2rtlil'):
    for m in ('default', 'testflags'): P(f'   {c_} {m}: {sum(1 for k in R0 if k[0] == c_ and k[1] == m)}')
conv = set(); pconv = set()
P('== 1. (what moved since map 14: drivers/delta15.py, README section 3)')
# ---------------------------------------------------------------- 2. yields
afterA = {k for k in RS if not RS[k] <= covA}; afterB = {k for k in RS if not RS[k] <= covB}; after = {k for k in RS if not RS[k] <= BOTH}
pafterA = {k for k in PS if not PS[k] <= covA}; pafterB = {k for k in PS if not PS[k] <= covB}; pafter = {k for k in PS if not PS[k] <= BOTH}
cleared = set(R0) - after
P('== 2. yields (row-modes / tests cleared in every NE mode / probe cases)')
P(f'   pair A {TAGS["pairA"]} optimistic ({len(covA)} clusters): {len(RS) - len(afterA)} / {len(tests(set(R0) - afterA, R0)) - len(tests(conv, R0))} / {len(PS) - len(pafterA)}')
P(f'   pair B {TAGS["pairB"]} optimistic ({len(covB)} clusters): {len(RS) - len(afterB)} / {len(tests(set(R0) - afterB, R0)) - len(tests(conv, R0))} / {len(PS) - len(pafterB)}')
P(f'   both pairs optimistic: {len(cleared)} row-modes / {len(tests(cleared, R0))} tests / {len(P0) - len(pafter)} probe')
for c_ in ('surelog', 'uhdm2rtlil'):
    for m in ('default', 'testflags'):
        f = lambda S: sum(1 for k in S if k[0] == c_ and k[1] == m)
        P(f'   {c_} {m}: today {f(R0)}; + pair A {f(afterA)}; + pair B {f(afterB)}; + both {f(after)}')
P(f'   FAIL LIST AFTER BOTH PAIRS: {len(after)} row-modes / {nt(after)} tests (today {len(R0)} / {nt(R0)}); probe {len(pafter)} (today {len(P0)}; + A {len(pafterA)}, + B {len(pafterB)})')
P('   rows cleared:', ' '.join(rk(k) + ('[A]' if k not in afterA else '[B]' if k not in afterB else '[A+B]') for k in sorted(cleared)))
NAMED = namA | namB
afterN = {k for k in RS if not RS[k] <= NAMED}; pafterN = {k for k in PS if not PS[k] <= NAMED}
clearedN = set(R0) - afterN
P(f'   NAMED ONLY (the decoded heads the brief items name, no row / family / first-ten credit: A {len(namA)} + B {len(namB)} clusters): {len(clearedN)} row-modes / {len(tests(clearedN, R0))} tests / {len(P0) - len(pafterN)} probe; FAIL LIST AFTER NAMED: {len(afterN)} row-modes / {nt(afterN)} tests, probe {len(pafterN)}')
P('   rows cleared (named):', ' '.join(rk(k) for k in sorted(clearedN)))
for c_ in ('surelog', 'uhdm2rtlil'):
    for m in ('default', 'testflags'):
        f = lambda S: sum(1 for k in S if k[0] == c_ and k[1] == m)
        P(f'   {c_} {m}: named-only after {f(afterN)}')
# ---------------------------------------------------------------- 3. per-cluster columns
def alone(c): return sum(1 for k in after if RS[k] <= BOTH | {c})
def first_open(k):
    for i in ORDER[('NEWL:', k)]:
        if i not in BOTH: return i
    return '-'
FO = {k: first_open(k) for k in after}
def first_open_named(k):
    for i in ORDER[('NEWL:', k)]:
        if i not in NAMED: return i
    return '-'
FON = {k: first_open_named(k) for k in afterN}
firstA = collections.Counter(FO[k] for k in after)
P0N = {c: len(pr0.get(c, ())) for c in ALL}
rank = sorted(ALL, key=lambda c: (-len(rc0.get(c, ())), -P0N[c], -ids['objC'].get(c, 0), c))
CI = {}
for i, c in enumerate(rank):
    rs = rc0.get(c, set()); m = M8.get(c, {})
    CI[c] = dict(cluster_id=c, rank=i + 1, rows=len(rs), rows_surelog=sum(1 for k in rs if k[0] == 'surelog'),
                 rows_uhdm2rtlil=sum(1 for k in rs if k[0] == 'uhdm2rtlil'), tests=nt(rs), objects=ids['objC'].get(c, 0) + ids['objP'].get(c, 0),
                 probe_cases=P0N[c], first_in_rows=sum(1 for k in rs if F0.get(k) == c), ground=ground(c), coverage=cov[c],
                 rows_after_pairs=0 if iscov(c) else len([k for k in rcS.get(c, ()) if k in after]),
                 probe_after_pairs=0 if iscov(c) else len([k for k in prS.get(c, ()) if k in pafter]),
                 first_in_after_pairs=firstA.get(c, 0), alone_on_top_of_pairs=0 if iscov(c) or c not in rcS else alone(c),
                 alone_on_pristine=len(yld({c}, R0)), rows_after_named=0 if c in NAMED else len([k for k in rcS.get(c, ()) if k in afterN]),
                 alone_on_top_of_named=0 if c in NAMED or c not in rcS else sum(1 for k in afterN if RS[k] <= NAMED | {c}),
                 map14_rows_551c9751=m.get('rows', '-'), map14_rows_after_pairs=m.get('rows_after_pairs', '-'), map14_probe=m.get('probe_cases', '-'),
                 map14_coverage=m.get('coverage', 'new'), map14_site=m.get('site', '-'), families=' '.join(sorted({fam(k[2]) for k in rs} - {''})),
                 example_tests=' '.join(sorted({red(k[2]) for k in rs})[:6]), site=site(c), writer=writer(c), writer_chain_grounds=chain_grounds(c), probe_laws=ids['plaws'].get(c, ''),
                 key=KEY[c], example=ids['exs'].get(KEY[c], ''))
os.makedirs(OUT, exist_ok=True)
with open(f'{OUT}/cluster_index.csv', 'w', newline='') as f:
    w = csv.DictWriter(f, list(next(iter(CI.values())).keys())); w.writeheader()
    for c in rank: w.writerow(CI[c])
def clr_tag(k):
    return ('yes (pair A, optimistic)' if k not in afterA else 'yes (pair B, optimistic)' if k not in afterB else 'yes (pairs A+B, optimistic)' if k not in after else 'no')
with open(f'{OUT}/fail_list.csv', 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['corpus', 'test', 'mode', 'strict', 'first_cluster', 'first_cluster_coverage', 'first_ground', 'first_site', 'first_writer', 'clusters',
                'open_clusters', 'family', 'downstream', 'first_open_cluster_after_pairs', 'open_clusters_after_pairs', 'clears', 'first_open_cluster_after_named', 'open_clusters_after_named', 'clears_named'])
    for k in sorted(R0):
        s = R0[k]; fc = F0[k]
        w.writerow([k[0], red(k[2]), k[1], strict0[k], fc, cov[fc], ground(fc), site(fc), writer(fc), len(s), sum(1 for c in s if not iscov(c)),
                    fam(k[2]), down.get(k[2], '') if k[0] == 'uhdm2rtlil' else '', FO.get(k, '-'), ' '.join(sorted(c for c in RS.get(k, set()) if c not in BOTH)), clr_tag(k),
                    FON.get(k, '-'), ' '.join(sorted(c for c in RS.get(k, set()) if c not in NAMED)), 'no' if k in afterN else 'yes (named)'])
with open(f'{OUT}/probe_fail_list.csv', 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['case', 'law', 'strict', 'first_cluster', 'first_cluster_coverage', 'first_ground', 'first_site', 'first_writer', 'clusters', 'open_clusters',
                'clears'])
    for k in sorted(P0):
        s = P0[k]; fc = PF0[k]
        t = ('yes (pair A, optimistic)' if k not in pafterA else 'yes (pair B, optimistic)' if k not in pafterB else 'yes (pairs A+B, optimistic)' if k not in pafter else 'no')
        w.writerow([k, LAWP.get(k, '-'), pstrict0[k], fc, cov[fc], ground(fc), site(fc), writer(fc), len(s), sum(1 for c in s if not iscov(c)), t])
json.dump(dict(afterN=['|'.join(k) for k in afterN], namA=sorted(namA), namB=sorted(namB), after=['|'.join(k) for k in after], covA=sorted(covA), covB=sorted(covB), LAWGONE=sorted(LAWGONE), conv=['|'.join(k) for k in conv],
               FIRST10B=sorted(FIRST10B)), open(f'{W}/report15_state.json', 'w'))
# ---------------------------------------------------------------- 4. ranked OPEN
esc = lambda s: str(s).replace('|', '\\|')
openr = [c for c in rank if not iscov(c) and CI[c]['rows_after_pairs'] > 0]
openr.sort(key=lambda c: (-CI[c]['rows_after_pairs'], -CI[c]['alone_on_top_of_pairs'], -CI[c]['first_in_after_pairs'], -CI[c]['probe_cases'], c))
P(f'== 4. OPEN clusters with a row after both pairs: {len(openr)} (ground A {sum(1 for c in openr if CI[c]["ground"] == "A")}, B {sum(1 for c in openr if CI[c]["ground"] == "B")}, ? {sum(1 for c in openr if CI[c]["ground"] == "?")})')
P(f'| # | cluster | rows left ({BL}) | sl/u2r | tests | families | heads | alone | probe | ground | status | key | writer of the field | site (mint < caller < caller) |')
P('|---|---|---|---|---|---|---|---|---|---|---|---|---|---|')
for i, c in enumerate(openr[:70]):
    r = CI[c]
    P(f"| {i+1} | {c} | {r['rows_after_pairs']} ({r['rows']}) | {r['rows_surelog']}/{r['rows_uhdm2rtlil']} | {r['tests']} | {r['families'] or '-'} | {r['first_in_after_pairs']} | {r['alone_on_top_of_pairs']} | {r['probe_cases']} | {r['ground']} | {esc(r['coverage'][:70])} | `{esc(r['key'])}` | {esc(r['writer'][:110])} | {esc(r['site'][:110])} |")
po = sorted((c for c in ALL if not iscov(c) and not rc0.get(c) and P0N[c]), key=lambda c: -len(prS.get(c, ())))
P('   probe-only OPEN clusters with the most cases:', ' '.join(f"{c} ({len(prS.get(c, ()))}, {ground(c)})" for c in po[:14]))
pl = collections.Counter(); tot = collections.Counter()
for k in P0:
    for law in LAWP.get(k, '-').split(): pl[law] += 1
for k, v in LAWP.items():
    for law in v.split(): tot[law] += 1
P('   laws with the most NE cases:', '; '.join(f'{a} {n}/{tot[a]}' for a, n in pl.most_common(12)))
# ---------------------------------------------------------------- 5. first clusters
P('== 5. first OPEN clusters of the rows left after both pairs (the earliest walk record whose cluster neither pair covers)')
P('| first cluster | row-modes it heads | ground | status | key | site |')
P('|---|---|---|---|---|---|')
for c, n in firstA.most_common(40):
    P(f"| {c} | {n} | {ground(c) if c in ALL else '?'} | {esc(cov.get(c, 'new-under-law')[:70])} | `{esc(KEY.get(c, c))}` | {esc(site(c)[:120]) if c in ALL else '-'} |")
P(f'   first clusters at {BL}:', ' '.join(f'{c}:{n}' for c, n in collections.Counter(F0.values()).most_common(30)))
P(f'   probe first clusters at {BL}:', ' '.join(f'{c}:{n}' for c, n in collections.Counter(PF0.values()).most_common(30)))
# ---------------------------------------------------------------- 6. covered
P(f'== 6. covered clusters (pairs A {TAGS["pairA"]} / B {TAGS["pairB"]} optimistic): rows at the base; probe')
P('| cluster | rows (sl/u2r) | probe | coverage | key |')
P('|---|---|---|---|---|')
for c in sorted((c for c in ALL if iscov(c)), key=lambda c: (cov[c][:15], -len(rc0.get(c, ())), -P0N[c], c)):
    r = CI[c]
    if r['rows'] == 0 and r['probe_cases'] < 3: continue
    P(f"| {c} | {r['rows']} ({r['rows_surelog']}/{r['rows_uhdm2rtlil']}) | {r['probe_cases']} | {esc(r['coverage'][:90])} | `{esc(r['key'])}` |")
# ---------------------------------------------------------------- 7. structural
P('== 7. structural rows (first field depth / type / count) and probe cases')
for tag, S0, RR, FF in ((BL, strict0, R0, F0),):
    st = sorted(k for k in RR if re.match(r'differ:(depth|type|count|stage1)', S0.get(k, '')))
    P(f'   {tag}: {len(st)} row-modes:', '; '.join(f'{rk(k)} {S0[k]} first={FF[k]} ({KEY.get(FF[k], FF[k])})' for k in st))
for tag, PP in ((BL, pstrict0),):
    pst = collections.Counter(re.match(r'differ:(\w+)', v).group(1) for v in PP.values() if re.match(r'differ:(depth|type|count)', v))
    P(f'   probe structural first fields {tag}:', dict(pst))
# ---------------------------------------------------------------- 8. greedy sets per ground (twice: on top of the optimistic pairs, and on top of the NAMED heads only)
def greedy_block(BOTH, after, label, greedy_out):
    tests_all = collections.defaultdict(list)
    for k in R0: tests_all[(k[0], k[2])].append(k)
    aopen = {k: {c for c in RS[k] if c not in BOTH} for k in after}
    base = len(R0) - len(after)
    def clr(S):
        ks = {k for k, s in aopen.items() if s <= S}
        tt = {t for t, ms in tests_all.items() if all((m not in after) or (m in ks) for m in ms)}
        return ks, tt
    nopen = collections.Counter(min(len(s), 6) for s in aopen.values())
    gmix = collections.Counter(('A' if all(ground(c) == 'A' for c in s if c in ALL) else 'B' if all(ground(c) == 'B' for c in s if c in ALL) else '?' if any((c not in ALL) or ground(c) == '?' for c in s) else 'both') for s in aopen.values())
    P(f'== 8{label}. greedy sets per ground on top of {"both pairs (optimistic)" if not label else "the NAMED heads only"}; base cleared {base} row-modes / {len(tests(set(R0) - after, R0))} tests')
    P('   rows left by open-cluster count (6 = 6+):', dict(sorted(nopen.items())), '; by ground:', dict(gmix))
    for g in ('A', 'B'):
        allg = {c for s in aopen.values() for c in s if c in ALL and ground(c) == g}
        P(f'   every OPEN cluster of ground {g} ({len(allg)}) clears {len(clr(allg)[0])} row-modes ({base + len(clr(allg)[0])} with the pairs)')
    GREEDY = greedy_out
    for g in ('A', 'B', 'A+B', 'deep A', 'deep B', 'deep A+B'):
        # r11u197: the 'deep' lists take a remaining row's WHOLE open set whatever its size (map 10's cap was 4 / 6 clusters)
        gg = g.split()[-1]; cap = 10**6 if g.startswith('deep') else (4 if gg != 'A+B' else 6)
        cands = {frozenset(s) for s in aopen.values() if 0 < len(s) <= cap and all(c in ALL and (ground(c) == gg or (gg == 'A+B' and ground(c) in 'AB')) for c in s)}
        cum = set(); P(f'## ground {g}: {len(cands)} candidate sets')
        P('| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |')
        P('|---|---|---|---|---|---|---|---|')
        GREEDY[g] = []
        for i in range(30 if g not in ('A+B', 'deep A+B') else 40):
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
            add = sorted(best[2]); GREEDY[g].append((add, best[3], newrows))
            P(f"| {i+1} | {' + '.join(add)} | {best[3]} | {base + len(ks)} | {len(tests(set(R0) - after | ks, R0))} | "
              f"{' '.join(red(k[2]) + '/' + k[1][0] + ('/u2r' if k[0] == 'uhdm2rtlil' else '') for k in newrows)} | "
              f"{'; '.join('`' + esc(KEY[c]) + '`' for c in add[:4])}{' ...' if len(add) > 4 else ''} | {esc(site(add[0]))[:150]} |")
        ks, tt = clr(cum)
        P(f'\nground {g}: the {len(cum)} clusters above clear {len(ks)} row-modes on top of the pairs ({base + len(ks)} with them)\n')

    return aopen
GREEDY = {}; GREEDYN = {}
aopen = greedy_block(BOTH, after, '', GREEDY)
_aopenN = greedy_block(NAMED, afterN, 'b', GREEDYN)
# ---------------------------------------------------------------- 9. family view
P('== 9. family view')
P(f'| family | row-modes / tests | clusters per row at {BL} | open per row after both pairs | distinct clusters: {BL} -> + pairs | cleared |')
P('|---|---|---|---|---|---|')
for n, f in FAM:
    ks = [k for k in R0 if f(k[2])]
    if not ks: continue
    c0 = [len(R0[k]) for k in ks]; cs = [len(RS.get(k, ())) for k in ks]; c1 = [len(aopen.get(k, ())) for k in ks]
    d0 = set().union(*[R0[k] for k in ks]); ds = set().union(*[RS.get(k, set()) for k in ks]); d1 = set().union(*[aopen.get(k, set()) for k in ks])
    P(f'| {n} | {len(ks)} / {nt(ks)} | {min(c0)}-{max(c0)} | {min(c1)}-{max(c1)} | {len(d0)} -> {len(d1)} | {sum(1 for k in ks if k not in after)} |')
near0 = sorted(k for k in R0 if len(R0[k]) == 1)
P(f'   single-cluster rows at 97343175: {len(near0)} row-modes / {nt(near0)} tests:', '; '.join(f'{rk(k)} {next(iter(R0[k]))}' for k in near0))
near = sorted(k for k in after if len(aopen[k]) == 1)
P(f'   NEAR rows (one open cluster after both pairs): {len(near)} row-modes / {nt(near)} tests:', '; '.join(f'{rk(k)} {next(iter(aopen[k]))}' for k in near))
two = sorted(k for k in after if len(aopen[k]) == 2)
P(f'   two open clusters: {len(two)} row-modes:', '; '.join(f"{rk(k)} {'+'.join(sorted(aopen[k]))}" for k in two))
json.dump({g: [dict(add=a, gain=n, rows=['|'.join(k) for k in r]) for a, n, r in v] for g, v in GREEDY.items()}, open(f'{W}/greedy15.json', 'w'))
json.dump({g: [dict(add=a, gain=n, rows=['|'.join(k) for k in r]) for a, n, r in v] for g, v in GREEDYN.items()}, open(f'{W}/greedy15_named.json', 'w'))
