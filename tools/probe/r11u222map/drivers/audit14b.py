#!/usr/bin/env python3
"""r11u222map: the prediction audit of map 13 (tools/probe/r11u211map, measured at 4acbe8a5, addendum at 62ac216e)
against the landings since: pass 207 (62ac216e), map 13 itself (baf91896, tools only), pass 209 (b69dc2da), the
verification r11u213 (6dcc0818), pass 210 (a727b8c7), pass 212 (745f66ab), the decode r11u214 (83ee16d6, tools only),
the verification r11u217 (0a682d73), pass 216 (c4f26079), the decode r11u218 (c624cafb, tools only), pass 215
(57ce3ae8), the verification r11u221 (162790c3), pass 219 (896ec643) and pass 220 (551c9751, r11u222's restart base). (map 13's audit13.py re-based; the labels
"map 12" in the printed text below read "map 13" and r11u200 / r11u201 / r11u202 read r11u205 / r11u207 / r11u209.) Conversions
are read from the committed baselines at each landing commit (git show <commit>:results/golden_*.csv), never from a
sweep. Map 12's predictions: (a) its fail_list.csv `clears` (r11u200 measured + pairs r11u201 / r11u202 optimistic),
(b) its section-9 greedy lists (evidence/greedy13.json). The landing laws of every converted test are transcribed from
the pass READMEs' verdict tables (LANDED); their files are read from src by the section sign. The site audit compares
those files with map 12's pin of the row's first cluster (fail_list.csv first_cluster -> cluster_index.csv site).
Args: <repo> <this map's out dir (cluster_index.csv)>"""
import csv, io, subprocess, sys, re, json, collections, os, glob
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import fenced
REPO, OUT = sys.argv[1:3]
M8 = f'{REPO}/tools/probe/r11u211map'   # the PREVIOUS map (map 13)
FEN = fenced(); red = lambda n: 'FENCED' if n in FEN else n
STEPS = [('4acbe8a55', 'map 13 base'), ('62ac216e3', 'pass 207'), ('baf918960', 'map 13'), ('b69dc2da0', 'pass 209'),
         ('6dcc0818c', 'r11u213'), ('a727b8c7d', 'pass 210'), ('745f66abf', 'pass 212'), ('83ee16d6a', 'r11u214'),
         ('0a682d736', 'r11u217'), ('c4f260792', 'pass 216'), ('c624cafb1', 'r11u218'), ('57ce3ae8b', 'pass 215'),
         ('162790c3b', 'r11u221'), ('896ec6439', 'pass 219'), ('551c97519', 'pass 220')]
def at(commit, f):
    return list(csv.DictReader(io.StringIO(subprocess.run(['git', '-C', REPO, 'show', f'{commit}:results/{f}'], capture_output=True, text=True).stdout)))
state = {}
for c, _ in STEPS:
    s = {}
    for corp in ('surelog', 'uhdm2rtlil'):
        for r in at(c, f'golden_{corp}.csv'): s[(corp, r['mode'], r['name'])] = (r['status'], r['strict'])
    state[c] = (s, {r['case']: (r['status'], r['strict']) for r in at(c, 'golden_probe.csv')})
conv = {}; pconv = {}; P = print
P('== A. conversions per landing since map 13 (committed baselines)')
for (c0, _), (c1, tag) in zip(STEPS, STEPS[1:]):
    s0, p0 = state[c0]; s1, p1 = state[c1]
    cv = sorted(k for k in s1 if s0.get(k, ('',))[0] == 'STRICT_NOTEQUAL' and s1[k][0] == 'CMP_EQUAL')
    ch = sorted(k for k in s1 if s0.get(k, ('',))[0] == 'STRICT_NOTEQUAL' and s1[k][0] == 'STRICT_NOTEQUAL' and s0[k][1] != s1[k][1])
    bad = sorted(k for k in s1 if s0.get(k, ('',))[0] == 'CMP_EQUAL' and s1[k][0] != 'CMP_EQUAL')
    ent = sorted(k for k in s1 if s1[k][0] == 'STRICT_NOTEQUAL' and s0.get(k, ('',))[0] != 'STRICT_NOTEQUAL')
    pc = sorted(k for k in p1 if p0.get(k, ('',))[0] == 'STRICT_NOTEQUAL' and p1[k][0] == 'EQUAL')
    for k in cv: conv[k] = tag
    for k in pc: pconv[k] = tag
    P(f'   {tag} ({c1}): {len(cv)} row-modes / {len({(k[0], k[2]) for k in cv})} tests, {len(pc)} probe cases, {len(ch)} strict-cell changes; left CMP_EQUAL {len(bad)}; entered STRICT_NOTEQUAL {len(ent)}')
    if cv: P('      ', ' '.join(f'{k[0][:3]}/{k[1][0]}/{red(k[2])}' for k in cv))
    if ch: P('       changes:', '; '.join(f'{k[0][:3]}/{k[1][0]}/{red(k[2])} {s0[k][1]}->{s1[k][1]}' for k in ch))
P(f'   total: {len(conv)} row-modes, {len(pconv)} probe cases')
LANDED = {
 'pass 207': {'UnitElabBlock': 'hiddenBlockVarMintNoFile207'},
 'pass 209': {'HierPathTypespec': 'pkgArrTdElemClone209', 'InterfaceStructMemberPort': 'portConnOpLeafChain209 modportOpOrphanReparent209'},
 'pass 210': {'FuncStructValSimple': 'memLeftReadsPatUnlocated210 pkgTopWidePatReplTsName210'},
 'pass 215': {'ibex_tracer': 'impPatCopyFirstListingUnparented215'},
 'pass 220': {'anon_struct_packed_dim': 'hpVarSelRangeIdxNamesByPath220'}}
SRC = sorted(glob.glob(f'{REPO}/src/*.cpp') + glob.glob(f'{REPO}/src/*.h'))
_txt = {p: open(p, errors='replace').read() for p in SRC}
def lawfiles(law):
    fs = [os.path.basename(p).rsplit('.', 1)[0] for p, t in _txt.items() if re.search(r'§ ' + law + r'\b', t)]
    fs = [f for f in fs if f != 'EmitHelpers'] or fs
    return fs
FL8 = {(r['corpus'], r['mode'], r['test']): r for r in csv.DictReader(open(f'{M8}/fail_list.csv'))}
CI8 = {r['cluster_id']: r for r in csv.DictReader(open(f'{M8}/cluster_index.csv'))}
predB = {k for k, r in FL8.items() if r['clears'].startswith('yes')}
# map 13 section 4: eight named optimisms (FuncStructVal d/t, InterfArrayBind d, HierPathTypespec t, cfg_func_width_loop d/t,
# struct_param_func_config d/t)
OPTI = {('surelog', m, 'FuncStructVal') for m in ('default', 'testflags')} | {('surelog', 'default', 'InterfArrayBind'), ('surelog', 'testflags', 'HierPathTypespec')} \
    | {('uhdm2rtlil', m, t) for t in ('cfg_func_width_loop', 'struct_param_func_config') for m in ('default', 'testflags')}
G = json.load(open(f'{M8}/evidence/greedy13.json'))
lists = collections.defaultdict(dict); lclu = collections.defaultdict(dict)
for g, steps in G.items():
    for i, st in enumerate(steps):
        for c in st['add']: lclu[g].setdefault(c, i + 1)
        for r in st['rows']:
            k = tuple(r.split('|')); lists[g][k] = (i + 1, ' + '.join(st['add'][:6]) + (' ...' if len(st['add']) > 6 else ''))
open8 = set(FL8)
P(f'== B. map 13 predicted, on its 4acbe8a5 fail list ({len(open8)} row-modes)')
P(f'   r11u205 (measured) + pairs r11u207 / r11u209 optimistic: {len(predB)} row-modes (of which {len(predB & OPTI)} named-optimism credits)')
for g in G: P(f'   section-9 list {g}: {len(lists[g])} row-modes')
anyp = predB | set().union(*[set(lists[g]) for g in G])
P(f'   predicted by any of them: {len(anyp)}')
by = collections.defaultdict(list)
for k in sorted(open8):
    tag = conv.get(k, 'open')
    pr = ('r11u205+pairs' + ('(optimism)' if k in OPTI else '') if k in predB else '') + ''.join(f' {g.replace(" ", "")}{lists[g][k][0]}' for g in G if k in lists[g])
    by[(pr.strip() or 'none', tag)].append(k)
P('   predicted-by x landed-by (row-modes):')
for (pr, tag), ks in sorted(by.items()):
    P(f'     {pr:48s} {tag:10s} {len(ks):3d}  ' + ' '.join(f'{k[0][:3]}/{k[1][0]}/{red(k[2])}' for k in ks[:40]))
tally = collections.Counter()
for k in open8:
    tally[('predicted' if k in anyp else 'not predicted', 'converted' if k in conv else 'open')] += 1
P('   tally:', dict(tally))
for g in G:
    s = set(lists[g]); P(f'   list {g}: {len(s)} predicted, {len(s & set(conv))} converted; still open:', ' '.join(f'{k[0][:3]}/{k[1][0]}/{red(k[2])}' for k in sorted(s - set(conv))))
P(f'   r11u205+pairs: {len(predB)} predicted, {len(predB & set(conv))} converted; open:', ' '.join(f'{k[0][:3]}/{k[1][0]}/{red(k[2])}' for k in sorted(predB - set(conv))))
P(f'   without the eight named optimisms: {len(predB - OPTI)} predicted, {len((predB - OPTI) & set(conv))} converted')
P('== C. per converted row: predicted by, map 13 first open cluster after its pairs and its pin, the landing law files')
file_of = lambda s: set(re.findall(r'\((\w+)\.(?:cpp|h)', s))
mint_of = lambda s: (re.findall(r'\((\w+)\.(?:cpp|h)', s) or ['?'])[0]
rows = []
for k, tag in sorted(conv.items(), key=lambda x: (x[1], x[0])):
    laws = LANDED.get(tag, {}).get(k[2], '?')
    lf = set(f for law in laws.split() for f in lawfiles(law)) if laws != '?' else set()
    fc0 = FL8.get(k, {}).get('first_cluster', '-')
    fc = FL8.get(k, {}).get('first_open_cluster_after_pairs', '-')
    if fc in ('-', ''): fc = fc0
    site = CI8.get(fc, {}).get('site', '-')
    verdict = ('pin right (mint)' if mint_of(site) in lf else 'pin right (a caller)' if lf & file_of(site) else 'pin misses') if site not in ('-', '') else 'no pin'
    site0 = CI8.get(fc0, {}).get('site', '-')
    verdict0 = ('pin right (mint)' if mint_of(site0) in lf else 'pin right (a caller)' if lf & file_of(site0) else 'pin misses') if site0 not in ('-', '') else 'no pin'
    pred = 'r11u205+pairs' + (' (named optimism)' if k in OPTI else '') if k in predB else next((f'list-{g} step {lists[g][k][0]}' for g in G if k in lists[g]), 'not predicted')
    rows.append(dict(landing=tag, row='/'.join(k), laws=laws, files='+'.join(sorted(lf)), first_cluster=fc0, first_open_after_pairs=fc,
                     pin_mint=mint_of(site0), verdict_first=verdict0, verdict=verdict, predicted=pred, clears=FL8.get(k, {}).get('clears', '')))
    P(f"   {tag:9s} {k[0][:3]}/{k[1][0]}/{red(k[2]):34s} {pred:32s} first={fc0} pin={mint_of(site0):14s} ({verdict0}) laws={laws} ({'+'.join(sorted(lf))}); map-13 clears={FL8.get(k, {}).get('clears', '')}")
P('   tally (landing, predicted):', dict(collections.Counter((r['landing'], 'predicted' if r['predicted'] != 'not predicted' else 'not predicted') for r in rows)))
P('   site verdicts (first cluster):', dict(collections.Counter(r['verdict_first'] for r in rows)))
# ---- cluster level
CI9 = {r['cluster_id']: r for r in csv.DictReader(open(f'{OUT}/cluster_index.csv'))} if os.path.exists(f'{OUT}/cluster_index.csv') else {}
B8 = {c for c, r in CI8.items() if r['coverage'].startswith('COVERED')}
L8 = {}
for g in G:
    for c, s in lclu[g].items(): L8.setdefault(c, f'{g.replace(" ", "")}{s}')
def fate(c):
    a = int(CI8[c]['rows']) if c in CI8 else 0
    b = int(CI9[c]['rows']) if c in CI9 else 0
    pa = int(CI8[c]['probe_after_law']) if c in CI8 else 0; pb = int(CI9[c]['probe_cases']) if c in CI9 else 0
    a0 = int(CI8[c]['rows']) if c in CI8 else 0
    return a0, b, pa, pb, ('gone' if b == 0 and pb == 0 else 'rows cleared' if b == 0 and a0 > 0 else 'fell' if b < a0 else 'unchanged' if b == a0 else 'grew')
for tag, S in (('map 13 covered (r11u205 measured + pairs r11u207 / r11u209 optimistic)', B8), ('map 13 section-9 lists', set(L8))):
    fs = collections.Counter(); det = collections.defaultdict(list)
    for c in sorted(S):
        a, b, pa, pb, f = fate(c); fs[f] += 1; det[f].append(f'{c}{"(" + L8[c] + ")" if c in L8 else ""} {a}->{b}')
    P(f'== D. {tag}: {len(S)} clusters (rows at 4acbe8a5 -> 551c9751): {dict(fs)}')
    for f, v in det.items(): P(f'     {f}: ' + ' '.join(v[:90]) + (' ...' if len(v) > 90 else ''))
unp = []
for c, r in CI8.items():
    if c in B8 or c in L8: continue
    a, b, pa, pb, f = fate(c)
    if (a > 0 and b < a) or (pa > 0 and pb < int(CI8[c]['probe_cases']) and pb == 0): unp.append((a - b, c, a, b, int(CI8[c]['probe_cases']), pb))
unp.sort(reverse=True)
P(f'== E. clusters map 13 did not route (covered / section 9) whose rows or probe cases cleared or fell: {len(unp)}:', ' '.join(f'{c} rows {a}->{b} probe {p0}->{p1}' for _, c, a, b, p0, p1 in unp[:70]))
json.dump(rows, open(os.path.join(os.path.dirname(OUT.rstrip('/')), 'audit_rows.json'), 'w'), indent=0)
ITEMS_MAP12 = [('B1', 'N2467 N2468', 'MiniAmiq'), ('B2a', 'N0090', 'arb_idx_cast'), ('B2b', 'N0011', 'UnitElabBlock'),
         ('B3a', 'N0519 N1117 N1126 N1128 N1134', 'InterfaceStructMemberPort'), ('B3b', 'N1081', 'ClassTypeParam'), ('B3c', 'N1174', 'HierPathTypespec'),
         ('B3d', 'N0853 N1127', 'OutputSizeWithParameterOfInstanceInitializedByStructMember'), ('B3e', 'N0014', 'anon_struct_packed_dim'),
         ('B3f', 'N0563', 'ibex_tracer'), ('B4', 'N0133 N0487', 'cfg_func_width_loop'),
         ('B5a', 'N0778', 'BuildUVMPkg'), ('B5b', 'N0945', 'Earlgrey_0_1'), ('B5c', 'N1249', 'Rggen'), ('B5d', 'N0144', 'MiniAmiq'),
         ('B6', 'N0288 N0121 N0262 N0318 N0321 N0337 N0266 N0043 N0078 N0426 N0974', 'MiniAmiq'),
         ('B7', 'N0056', 'PreprocTest'), ('B7b', 'N0083 N0422 N0484 N1149', 'LogicTypespec'), ('B7c', 'N0791', 'Scr1SvTests'),
         ('A1', 'N0016', 'UnitElabBlock'), ('A2', 'N0540 N0689', 'MiniAmiq'),
         ('A3a', 'N0045 N0675 N2412 N0028 N0552 N0761 N0817', 'struct_param_func_config'), ('A3b', 'N0754 N0794 N0263 N0025 N0033', 'cfg_func_width_loop'),
         ('A4', 'N0290 N0098 N0303 N0304 N0305 N0306 N0050 N0123 N0297 N0314 N0326 N0352 N0374 N0375 N0387 N0390 N0392 N0397 N0399', 'SimpleUVM'),
         ('A5', 'N0923', 'BlackBePipeInt'), ('A6', 'N0739 N1903 N1904 N0476 N0477', '-'),
         ('pA', 'N0217 N0175 N0220', 'SeqDriver'), ('pA2', 'N0682', 'SimpleUVM'), ('pA3', 'N0086 N0087 N0131', 'FuncStructValSimple'),
         ('pA4', 'N0407 N0891 N0980 N1096', 'FuncStructVal'), ('pA5', 'N0427', 'InterfArrayBind'), ('pA6', 'N0820', 'anon_struct_packed_dim'),
         ('pA7', 'N0191 N0001', 'OutputSizeWithParameterOfInstanceInitializedByStructMember'), ('pA8', 'N0003 N0763 N0957 N0971 N0979', 'ibex_tracer'),
         ('pB', 'N0040', 'InterfaceModPort'), ('pB2', 'N0039', 'BuildUVMPkg')]
ITEMS = [('A-r207', 'N0540 N0689 N0923 N0016', 'MiniAmiq'), ('A-r207b', 'N0416 N0779 N0836 N1069 N1119', 'Scr1SvTests'),
         ('A-cfg', 'N0263 N0025 N0033 N0754 N0794', 'cfg_func_width_loop'), ('A-spfc', 'N0028 N0045 N0552 N0675 N0761 N0817 N2412', 'struct_param_func_config'),
         ('A-iab', 'N0427', 'InterfArrayBind'), ('A-fsv', 'N0086 N0087 N0131 N0407 N0891 N0980 N1096 N1946', 'FuncStructVal'),
         ('A-fsvs', 'N0086 N0087 N0131', 'FuncStructValSimple'), ('A-anon', 'N0820', 'anon_struct_packed_dim'),
         ('A-ibex', 'N0003 N0763 N0957 N0971 N0979', 'ibex_tracer'), ('A-os', 'N0001 N0191', 'OutputSizeWithParameterOfInstanceInitializedByStructMember'),
         ('A-uvmhead', 'N0582 N0900 N1424', 'SimpleUVM'), ('A-bb', 'N0897', 'BlackBePipeInt'),
         ('A-case', 'N0739 N1903 N1904 N0476 N0477', '-'),
         ('B-r205', 'N0945 N0915 N0924 N1116 N1121 N0145 N1249 N1677', 'Earlgrey_0_1'), ('B-206', 'N0014', 'anon_struct_packed_dim'),
         ('B-ismp', 'N0519 N1117 N1126 N1128 N1134', 'InterfaceStructMemberPort'), ('B-hpt', 'N1174', 'HierPathTypespec'),
         ('B-cfg', 'N0133 N0487', 'cfg_func_width_loop'), ('B-os', 'N0853 N1127', 'OutputSizeWithParameterOfInstanceInitializedByStructMember'),
         ('B-ibex', 'N0563', 'ibex_tracer'), ('B-rg', 'N0145 N1249 N0727', 'Rggen'), ('B-899', 'N0144', 'MiniAmiq'), ('B-3245', 'N0039', 'BuildUVMPkg'),
         ('B-778', 'N0778', 'BuildUVMPkg'), ('B-eg', 'N0073', 'Earlgrey_0_1'), ('B-imp', 'N0040', 'InterfaceModPort'), ('B-pp', 'N0056', 'PreprocTest'),
         ('B-lt', 'N0083 N0422 N0484 N1149', 'LogicTypespec'), ('B-scr', 'N0791 N0284', 'Scr1SvTests'),
         ('B-clone', 'N0480 N0485 N0510 N0511 N0512 N0513 N0514 N0516', 'MiniAmiq'), ('B-sb', 'N0008 N0151 N0447 N0458 N0467 N0691 N0692 N0732 N0734', 'Scoreboard')]
P('== F. map 13 section-9 items and pair routes recounted at 551c9751 (rows = row-modes carrying the cluster; the row = the item\'s target)')
P('| item | clusters | rows 4acbe8a5 -> 551c9751 (per cluster) | probe 4acbe8a5 -> 551c9751 | target row status 551c9751 | converted by |')
P('|---|---|---|---|---|---|')
last = state[STEPS[-1][0]][0]
for it, cl, t in ITEMS:
    per = ' '.join(f"{c} {CI8[c]['rows'] if c in CI8 else '-'}->{CI9[c]['rows'] if c in CI9 else 0}" for c in cl.split())
    pp = ' '.join(f"{CI8[c]['probe_cases'] if c in CI8 else '-'}->{CI9[c]['probe_cases'] if c in CI9 else 0}" for c in cl.split())
    corp = 'uhdm2rtlil' if any(k[0] == 'uhdm2rtlil' and k[2] == t for k in last) else 'surelog'
    st = ' / '.join(f"{m[0]}:{last.get((corp, m, t), ('-', ''))[0]}" for m in ('default', 'testflags'))
    by = ' '.join(sorted({conv[k] for k in conv if k[2] == t})) or '-'
    P(f'| {it} | {cl} | {per} | {pp} | {red(t)} {st} | {by} |')
