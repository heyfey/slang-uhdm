#!/usr/bin/env python3
"""r11u189: the prediction audit of map 9 (tools/probe/r11u179map, at 5e8d08d9) against the landings since:
the verification r11u182 (312e26e2), passes 178 (80a1c2af), 176 (804e3b75), 181 (1eeff71d), the decode r11u183
(459b7cdf, tools only), pass 180 (a3a62624) and the verification r11u185 (2b97649e). Conversions are read from the
committed baselines at each landing commit (git show <commit>:results/golden_*.csv), never from a sweep. Map 9's
predictions: (a) r11u175 measured + the pairs r11u178 / r11u176 optimistic (fail_list.csv `clears`), plus its named-row
upper bound (FuncStructValSimple d/t, OneNetModPort d/t), (b) its section-9 greedy lists (evidence/report.txt section 8:
ground A, ground B, joint A+B). The landing laws of every converted test are transcribed from the pass READMEs'
targeted-row tables (LANDED); their files are read from src by the section sign. The site audit compares those files
with map 9's pin of the row's first cluster (fail_list.csv first_open_cluster_after_pairs, else first_cluster ->
cluster_index.csv site).
Args: <repo> <map-10 out dir (cluster_index.csv)>"""
import csv, io, subprocess, sys, re, json, collections, os, glob
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import fenced
REPO, OUT = sys.argv[1:3]
M8 = f'{REPO}/tools/probe/r11u179map'   # the PREVIOUS map (map 9); the name is kept from audit9.py
FEN = fenced(); red = lambda n: 'FENCED' if n in FEN else n
STEPS = [('5e8d08d9', 'map 9 base'), ('312e26e2', 'r11u182'), ('80a1c2af', 'pass 178'), ('804e3b75', 'pass 176'),
         ('1eeff71d', 'pass 181'), ('459b7cdf', 'r11u183'), ('a3a62624', 'pass 180'), ('2b97649e', 'r11u185')]
def at(commit, f):
    return list(csv.DictReader(io.StringIO(subprocess.run(['git', '-C', REPO, 'show', f'{commit}:results/{f}'], capture_output=True, text=True).stdout)))
state = {}
for c, _ in STEPS:
    s = {}
    for corp in ('surelog', 'uhdm2rtlil'):
        for r in at(c, f'golden_{corp}.csv'): s[(corp, r['mode'], r['name'])] = (r['status'], r['strict'])
    state[c] = (s, {r['case']: (r['status'], r['strict']) for r in at(c, 'golden_probe.csv')})
conv = {}; pconv = {}; P = print
P('== A. conversions per landing since map 9 (committed baselines)')
for (c0, _), (c1, tag) in zip(STEPS, STEPS[1:]):
    s0, p0 = state[c0]; s1, p1 = state[c1]
    cv = sorted(k for k in s1 if s0.get(k, ('',))[0] == 'STRICT_NOTEQUAL' and s1[k][0] == 'CMP_EQUAL')
    ch = sorted(k for k in s1 if s0.get(k, ('',))[0] == 'STRICT_NOTEQUAL' and s1[k][0] == 'STRICT_NOTEQUAL' and s0[k][1] != s1[k][1])
    bad = sorted(k for k in s1 if s0.get(k, ('',))[0] == 'CMP_EQUAL' and s1[k][0] != 'CMP_EQUAL')
    pc = sorted(k for k in p1 if p0.get(k, ('',))[0] == 'STRICT_NOTEQUAL' and p1[k][0] == 'EQUAL')
    for k in cv: conv[k] = tag
    for k in pc: pconv[k] = tag
    P(f'   {tag} ({c1}): {len(cv)} row-modes / {len({(k[0], k[2]) for k in cv})} tests, {len(pc)} probe cases, {len(ch)} strict-cell changes; left CMP_EQUAL {len(bad)}')
    if cv: P('      ', ' '.join(f'{k[0][:3]}/{k[1][0]}/{red(k[2])}' for k in cv))
P(f'   total: {len(conv)} row-modes, {len(pconv)} probe cases')
LANDED = {
 'pass 178': {'LocalScopeHierPath': 'hierPathSelIdxAtPath178'},
 'pass 176': {'OneNetModPort': 'progTypedPortLowConnUnlocated176 progLowConnDefModport176',
   'OneNetModPortGeneric': 'genericMpConnLowConnAtDecl176 progLowConnDefModport176 genericPlainNamedView176',
   'UnsizedParam': 'castRhsClonePerInst176'},
 'pass 181': {'CovMacro': 'rootPathFullNameByChain181', 'YosysRiscv': 'bitSelParenIdxSpan181'},
 'pass 180': {'PackedArrayHighConn': 'enumImportParentLastWriter180', 'mem_read_reg': 'ifaceWildcardTdNameOrder180'}}
SRC = sorted(glob.glob(f'{REPO}/src/*.cpp') + glob.glob(f'{REPO}/src/*.h'))
_txt = {p: open(p, errors='replace').read() for p in SRC}
def lawfiles(law):
    fs = [os.path.basename(p).rsplit('.', 1)[0] for p, t in _txt.items() if re.search(r'§ ' + law + r'\b', t)]
    fs = [f for f in fs if f != 'EmitHelpers'] or fs   # EmitHelpers.h holds the switch block of most ground-A passes
    return fs
# ---- map 8's predictions
FL8 = {(r['corpus'], r['mode'], r['test']): r for r in csv.DictReader(open(f'{M8}/fail_list.csv'))}
CI8 = {r['cluster_id']: r for r in csv.DictReader(open(f'{M8}/cluster_index.csv'))}
predB = {k for k, r in FL8.items() if r['clears'].startswith('yes')}
NAMED = {k for k in FL8 if k[2] in ('FuncStructValSimple', 'OneNetModPort')}   # map 9 section 5: the named-row upper bound
lists = collections.defaultdict(dict); cur = None; lclu = collections.defaultdict(dict)
for l in open(f'{M8}/evidence/report.txt'):
    m = re.match(r'## ground (\S+):', l)
    if m: cur = m.group(1); continue
    m = re.match(r'\| (\d+) \| ([N0-9 +]+) \| (\d+) \| \d+ \| \d+ \| ([^|]*) \|', l)
    if m and cur:
        for c in m.group(2).split('+'): lclu[cur][c.strip()] = int(m.group(1))
        for tok in m.group(4).split():
            p = tok.split('/'); t = p[0]; mode = 'default' if p[1] == 'd' else 'testflags'; corp = 'uhdm2rtlil' if len(p) > 2 else 'surelog'
            lists[cur][(corp, mode, t)] = (int(m.group(1)), m.group(2).strip())
open8 = {k for k in FL8}
P(f'== B. map 9 predicted, on its 5e8d08d9 fail list ({len(open8)} row-modes)')
P(f'   r11u175 (measured) + pairs r11u178 / r11u176 optimistic: {len(predB)} row-modes; named-row upper bound adds {len(NAMED - predB)}')
for g in ('A', 'B', 'A+B'): P(f'   section-9 list {g}: {len(lists[g])} row-modes')
anyp = predB | NAMED | set(lists['A']) | set(lists['B']) | set(lists['A+B'])
P(f'   predicted by any of them: {len(anyp)}')
by = collections.defaultdict(list)
for k in sorted(open8):
    tag = conv.get(k, 'open')
    pr = ('r11u175+pairs' if k in predB else 'named' if k in NAMED else '') + ''.join(f' {g}{lists[g][k][0]}' for g in ('A', 'B', 'A+B') if k in lists[g])
    by[(pr.strip() or 'none', tag)].append(k)
P('   predicted-by x landed-by (row-modes):')
for (pr, tag), ks in sorted(by.items()):
    P(f'     {pr:28s} {tag:10s} {len(ks):3d}  ' + ' '.join(f'{k[0][:3]}/{k[1][0]}/{red(k[2])}' for k in ks[:40]))
tally = collections.Counter()
for k in open8:
    tally[('predicted' if k in anyp else 'not predicted', 'converted' if k in conv else 'open')] += 1
P('   tally:', dict(tally))
for g in ('A', 'B', 'A+B'):
    s = set(lists[g]); P(f'   list {g}: {len(s)} predicted, {len(s & set(conv))} converted:', ' '.join(f'{k[0][:3]}/{k[1][0]}/{red(k[2])}' for k in sorted(s - set(conv))), '(still open)')
P(f'   r11u175+pairs: {len(predB)} predicted, {len(predB & set(conv))} converted; open:', ' '.join(f'{k[0][:3]}/{k[1][0]}/{red(k[2])}' for k in sorted(predB - set(conv))))
P('== C. per converted row: predicted by, map 9 first open cluster after its pairs and its pin, the landing law files')
file_of = lambda s: set(re.findall(r'\((\w+)\.(?:cpp|h)', s))
mint_of = lambda s: (re.findall(r'\((\w+)\.(?:cpp|h)', s) or ['?'])[0]
rows = []
for k, tag in sorted(conv.items(), key=lambda x: (x[1], x[0])):
    laws = LANDED.get(tag, {}).get(k[2], '?')
    lf = set(f for law in laws.split() for f in lawfiles(law)) if laws != '?' else set()
    fc = FL8.get(k, {}).get('first_open_cluster_after_pairs', '-')
    if fc in ('-', ''): fc = FL8.get(k, {}).get('first_cluster', '-')
    site = CI8.get(fc, {}).get('site', '-')
    verdict = ('pin right (mint)' if mint_of(site) in lf else 'pin right (a caller)' if lf & file_of(site) else 'pin misses') if site not in ('-', '') else 'no pin'
    pred = 'r11u175+pairs' if k in predB else 'named row' if k in NAMED else next((f'list-{g} step {lists[g][k][0]} ({lists[g][k][1]})' for g in ('A+B', 'A', 'B') if k in lists[g]), 'not predicted')
    rows.append(dict(landing=tag, row='/'.join(k), laws=laws, files='+'.join(sorted(lf)), first_cluster=fc, pin_mint=mint_of(site), verdict=verdict, predicted=pred,
                     cleared_clusters=FL8.get(k, {}).get('open_clusters_after_pairs', '')))
    P(f"   {tag:9s} {k[0][:3]}/{k[1][0]}/{red(k[2]):34s} {pred:44s} first={fc} pin={mint_of(site):14s} laws={laws} ({'+'.join(sorted(lf))}) -> {verdict}")
P('   tally (landing, predicted):', dict(collections.Counter((r['landing'], 'predicted' if r['predicted'] != 'not predicted' else 'not predicted') for r in rows)))
P('   site verdicts:', dict(collections.Counter(r['verdict'] for r in rows)))
P('   site verdicts by landing:', dict(collections.Counter((r['landing'], r['verdict']) for r in rows)))
# ---- cluster level
CI9 = {r['cluster_id']: r for r in csv.DictReader(open(f'{OUT}/cluster_index.csv'))} if os.path.exists(f'{OUT}/cluster_index.csv') else {}
B8 = {c for c, r in CI8.items() if r['coverage'].startswith('COVERED')}
L8 = {}
for g in ('A', 'B', 'A+B'):
    for c, s in lclu[g].items(): L8.setdefault(c, f'{g}{s}')
def fate(c):
    a = int(CI8[c]['rows_after_law']) if c in CI8 else 0
    b = int(CI9[c]['rows']) if c in CI9 else 0
    pa = int(CI8[c]['probe_after_law']) if c in CI8 else 0; pb = int(CI9[c]['probe_cases']) if c in CI9 else 0
    return a, b, pa, pb, ('gone' if b == 0 and pb == 0 else 'rows cleared' if b == 0 and a > 0 else 'fell' if b < a else 'unchanged' if b == a else 'grew')
for tag, S in (('map 9 covered (r11u175 measured + pairs r11u178 / r11u176 optimistic)', B8), ('map 9 section-9 lists', set(L8))):
    fs = collections.Counter(); det = collections.defaultdict(list)
    for c in sorted(S):
        a, b, pa, pb, f = fate(c); fs[f] += 1; det[f].append(f'{c}{"(" + L8[c] + ")" if c in L8 else ""} {a}->{b}')
    P(f'== D. {tag}: {len(S)} clusters: {dict(fs)}')
    for f, v in det.items(): P(f'     {f}: ' + ' '.join(v[:80]) + (' ...' if len(v) > 80 else ''))
unp = []
for c, r in CI8.items():
    if c in B8 or c in L8: continue
    a, b, pa, pb, f = fate(c)
    if a > 0 and b < a: unp.append((a - b, c, a, b))
unp.sort(reverse=True)
P(f'== E. clusters map 9 did not route (covered / section 9) whose rows cleared or fell: {len(unp)}:', ' '.join(f'{c} {a}->{b}' for _, c, a, b in unp[:60]))
json.dump(rows, open(f'{OUT}/../audit_rows.json' if False else os.path.join(os.path.dirname(OUT.rstrip('/')), 'audit_rows.json'), 'w'), indent=0)
# ---- F. the brief's recount: map 9's section-9 items, cluster by cluster, through passes 176-181 and 180
ITEMS = [('B1', 'N0056', 'PreprocTest'), ('B2', 'N0014', 'StructParamPatternInitCast'), ('B3', 'N0163', 'PackedArrayHighConn'),
         ('B4', 'N0129', 'ibex_icache'), ('B5', 'N0688', 'iface_zero_width_field'), ('B6', 'N0072 N0103', 'ArrayMethodIterator'),
         ('B7', 'N0804 N0805', 'mem_read_reg'), ('B8', 'N1174', 'HierPathTypespec'), ('B9', 'N0043 N0133 N0487', 'const_cast_signext'),
         ('B10', 'N0268 N0418 N0419', 'OneNetModPort'), ('B11', 'N0067 N0068 N0162 N0289', 'ApbSlave'), ('B12', 'N0083 N0422 N0484 N1149', 'LogicTypespec'),
         ('A1', 'N0131', 'FuncStructValSimple'), ('A2a', 'N0416 N0022 N0023', 'rsp_gen_minimal'), ('A2b', 'N0938 N0031', 'jeras_union'),
         ('A2c', 'N0191 N0001 N0853 N1127', 'OutputSizeWithParameterOfInstanceInitializedByStructMember'), ('A2d', 'N0443 N0684 N0448', 'arb_idx_cast'),
         ('A2e', 'N0299 N0628 N0627 N0431 N1047', 'AssertDelayError'), ('A2f', 'N0476 N0477 N0499', 'ParameterFromPkgInNestedModule'),
         ('A3', 'N0682 N0001 N0007 N0061 N0119 N0152 N0153', 'SimpleUVM')]
P('== F. map 9 section-9 items recounted at 2b97649e (rows = row-modes carrying the cluster; the row = the item\'s target)')
P('| item | clusters | rows 5e8d08d9 -> 2b97649e (per cluster) | probe 5e8d08d9 -> 2b97649e | target row status 2b97649e | converted by |')
P('|---|---|---|---|---|---|')
last = state[STEPS[-1][0]][0]
for it, cl, t in ITEMS:
    per = ' '.join(f"{c} {CI8[c]['rows'] if c in CI8 else '-'}->{CI9[c]['rows'] if c in CI9 else 0}" for c in cl.split())
    pp = ' '.join(f"{CI8[c]['probe_cases'] if c in CI8 else '-'}->{CI9[c]['probe_cases'] if c in CI9 else 0}" for c in cl.split())
    corp = 'uhdm2rtlil' if any(k[0] == 'uhdm2rtlil' and k[2] == t for k in last) else 'surelog'
    st = ' / '.join(f"{m[0]}:{last.get((corp, m, t), ('-', ''))[0]}" for m in ('default', 'testflags'))
    by = ' '.join(sorted({conv[k] for k in conv if k[2] == t})) or '-'
    P(f'| {it} | {cl} | {per} | {pp} | {red(t)} {st} | {by} |')
