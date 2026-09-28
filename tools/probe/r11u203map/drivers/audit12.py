#!/usr/bin/env python3
"""r11u203: the prediction audit of map 11 (tools/probe/r11u197map, measured at 4a65840e) against the landings since:
pass 193 (b8719ea9, landed after map 11's measurement, before its commit), map 11 itself (58905f76, tools only),
pass 195 (7eb6f4b5), the verification r11u199 (a015c911), pass 198 (cffb131f), pass 196 (c029f423) and the decode
r11u200 (ddc67d87, tools only). Conversions are read from the committed baselines at each landing commit
(git show <commit>:results/golden_*.csv), never from a sweep. Map 11's predictions: (a) its fail_list.csv `clears`
(r11u191 measured + pairs r11u195 / r11u193 optimistic), (b) its section-9 greedy lists (evidence/greedy11.json:
A, B, A+B, deep A, deep B, deep A+B). The landing laws of every converted test are transcribed from the pass READMEs'
verdict tables (LANDED); their files are read from src by the section sign. The site audit compares those files
with map 11's pin of the row's first cluster (fail_list.csv first_open_cluster_after_pairs, else first_cluster ->
cluster_index.csv site).
Args: <repo> <this map's out dir (cluster_index.csv)>"""
import csv, io, subprocess, sys, re, json, collections, os, glob
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import fenced
REPO, OUT = sys.argv[1:3]
M8 = f'{REPO}/tools/probe/r11u197map'   # the PREVIOUS map (map 11)
FEN = fenced(); red = lambda n: 'FENCED' if n in FEN else n
STEPS = [('4a65840e', 'map 11 base'), ('b8719ea92', 'pass 193'), ('58905f763', 'map 11'), ('7eb6f4b56', 'pass 195'),
         ('a015c9113', 'r11u199'), ('cffb131f0', 'pass 198'), ('c029f423b', 'pass 196'), ('ddc67d871', 'r11u200')]
def at(commit, f):
    return list(csv.DictReader(io.StringIO(subprocess.run(['git', '-C', REPO, 'show', f'{commit}:results/{f}'], capture_output=True, text=True).stdout)))
state = {}
for c, _ in STEPS:
    s = {}
    for corp in ('surelog', 'uhdm2rtlil'):
        for r in at(c, f'golden_{corp}.csv'): s[(corp, r['mode'], r['name'])] = (r['status'], r['strict'])
    state[c] = (s, {r['case']: (r['status'], r['strict']) for r in at(c, 'golden_probe.csv')})
conv = {}; pconv = {}; P = print
P('== A. conversions per landing since map 11 (committed baselines)')
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
 'pass 193': {'rsp_gen_minimal': 'castOperandLeafElab193 connCastTsNamedByPort193'},
 'pass 195': {'StructParamPatternInitCast': 'funcCfgPatOpRefBare195'},
 'pass 198': {'ibex_pmp': 'tfArgOutsideCopyOrder193 callArgVarSelStamp198'},   # ibex_pmp: pass 193 cleared its first record N0219 (file(5) -> type(1)), pass 198 the last (N0943)
 'pass 196': {'const_cast_signext': 'evalFuncCastMemberKeepsCall191', 'func_typename_ret': 'retPkgQualTdNoAlias196'}}
SRC = sorted(glob.glob(f'{REPO}/src/*.cpp') + glob.glob(f'{REPO}/src/*.h'))
_txt = {p: open(p, errors='replace').read() for p in SRC}
def lawfiles(law):
    fs = [os.path.basename(p).rsplit('.', 1)[0] for p, t in _txt.items() if re.search(r'§ ' + law + r'\b', t)]
    fs = [f for f in fs if f != 'EmitHelpers'] or fs
    return fs
FL8 = {(r['corpus'], r['mode'], r['test']): r for r in csv.DictReader(open(f'{M8}/fail_list.csv'))}
CI8 = {r['cluster_id']: r for r in csv.DictReader(open(f'{M8}/cluster_index.csv'))}
predB = {k for k, r in FL8.items() if r['clears'].startswith('yes')}
# map 11 section 5: five named optimisms (InterfaceModPort d/t, InterfArrayBind d, ClassTypeParam d/t, FuncStructVal d/t, HierPathTypespec t)
OPTI = {('surelog', m, t) for t in ('InterfaceModPort', 'ClassTypeParam', 'FuncStructVal') for m in ('default', 'testflags')} | {('surelog', 'default', 'InterfArrayBind'), ('surelog', 'testflags', 'HierPathTypespec')}
G = json.load(open(f'{M8}/evidence/greedy11.json'))
lists = collections.defaultdict(dict); lclu = collections.defaultdict(dict)
for g, steps in G.items():
    for i, st in enumerate(steps):
        for c in st['add']: lclu[g].setdefault(c, i + 1)
        for r in st['rows']:
            k = tuple(r.split('|')); lists[g][k] = (i + 1, ' + '.join(st['add'][:6]) + (' ...' if len(st['add']) > 6 else ''))
open8 = set(FL8)
P(f'== B. map 11 predicted, on its 4a65840e fail list ({len(open8)} row-modes)')
P(f'   r11u191 (measured) + pairs r11u195 / r11u193 optimistic: {len(predB)} row-modes (of which {len(predB & OPTI)} named-optimism credits)')
for g in G: P(f'   section-9 list {g}: {len(lists[g])} row-modes')
anyp = predB | set().union(*[set(lists[g]) for g in G])
P(f'   predicted by any of them: {len(anyp)}')
by = collections.defaultdict(list)
for k in sorted(open8):
    tag = conv.get(k, 'open')
    pr = ('r11u191+pairs' + ('(optimism)' if k in OPTI else '') if k in predB else '') + ''.join(f' {g.replace(" ", "")}{lists[g][k][0]}' for g in G if k in lists[g])
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
P(f'   r11u191+pairs: {len(predB)} predicted, {len(predB & set(conv))} converted; open:', ' '.join(f'{k[0][:3]}/{k[1][0]}/{red(k[2])}' for k in sorted(predB - set(conv))))
P(f'   without the five named optimisms: {len(predB - OPTI)} predicted, {len((predB - OPTI) & set(conv))} converted')
P('== C. per converted row: predicted by, map 11 first open cluster after its pairs and its pin, the landing law files')
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
    pred = 'r11u191+pairs' + (' (named optimism)' if k in OPTI else '') if k in predB else next((f'list-{g} step {lists[g][k][0]}' for g in G if k in lists[g]), 'not predicted')
    rows.append(dict(landing=tag, row='/'.join(k), laws=laws, files='+'.join(sorted(lf)), first_cluster=fc0, first_open_after_pairs=fc,
                     pin_mint=mint_of(site0), verdict_first=verdict0, verdict=verdict, predicted=pred, clears=FL8.get(k, {}).get('clears', '')))
    P(f"   {tag:9s} {k[0][:3]}/{k[1][0]}/{red(k[2]):34s} {pred:32s} first={fc0} pin={mint_of(site0):14s} ({verdict0}) laws={laws} ({'+'.join(sorted(lf))}); map-11 clears={FL8.get(k, {}).get('clears', '')}")
P('   tally (landing, predicted):', dict(collections.Counter((r['landing'], 'predicted' if r['predicted'] != 'not predicted' else 'not predicted') for r in rows)))
P('   site verdicts (first cluster):', dict(collections.Counter(r['verdict_first'] for r in rows)))
# ---- cluster level
CI9 = {r['cluster_id']: r for r in csv.DictReader(open(f'{OUT}/cluster_index.csv'))} if os.path.exists(f'{OUT}/cluster_index.csv') else {}
B8 = {c for c, r in CI8.items() if r['coverage'].startswith('COVERED')}
L8 = {}
for g in G:
    for c, s in lclu[g].items(): L8.setdefault(c, f'{g.replace(" ", "")}{s}')
def fate(c):
    a = int(CI8[c]['rows_after_law']) if c in CI8 else 0
    b = int(CI9[c]['rows']) if c in CI9 else 0
    pa = int(CI8[c]['probe_after_law']) if c in CI8 else 0; pb = int(CI9[c]['probe_cases']) if c in CI9 else 0
    a0 = int(CI8[c]['rows']) if c in CI8 else 0
    return a0, b, pa, pb, ('gone' if b == 0 and pb == 0 else 'rows cleared' if b == 0 and a0 > 0 else 'fell' if b < a0 else 'unchanged' if b == a0 else 'grew')
for tag, S in (('map 11 covered (r11u191 measured + pairs r11u195 / r11u193 optimistic)', B8), ('map 11 section-9 lists', set(L8))):
    fs = collections.Counter(); det = collections.defaultdict(list)
    for c in sorted(S):
        a, b, pa, pb, f = fate(c); fs[f] += 1; det[f].append(f'{c}{"(" + L8[c] + ")" if c in L8 else ""} {a}->{b}')
    P(f'== D. {tag}: {len(S)} clusters (rows at 4a65840e -> ddc67d87): {dict(fs)}')
    for f, v in det.items(): P(f'     {f}: ' + ' '.join(v[:90]) + (' ...' if len(v) > 90 else ''))
unp = []
for c, r in CI8.items():
    if c in B8 or c in L8: continue
    a, b, pa, pb, f = fate(c)
    if (a > 0 and b < a) or (pa > 0 and pb < int(CI8[c]['probe_cases']) and pb == 0): unp.append((a - b, c, a, b, int(CI8[c]['probe_cases']), pb))
unp.sort(reverse=True)
P(f'== E. clusters map 11 did not route (covered / section 9) whose rows or probe cases cleared or fell: {len(unp)}:', ' '.join(f'{c} rows {a}->{b} probe {p0}->{p1}' for _, c, a, b, p0, p1 in unp[:70]))
json.dump(rows, open(os.path.join(os.path.dirname(OUT.rstrip('/')), 'audit_rows.json'), 'w'), indent=0)
ITEMS = [('A1', 'N0045 N0675 N2412', 'struct_param_func_config'), ('A2', 'N0754 N0794', 'cfg_func_width_loop'),
         ('A3', 'N0741 N0779 N0836 N1069 N1119', 'Scr1SvTests'), ('A4a', 'N0941', 'Earlgrey_0_1'), ('A4b', 'N0145', 'Rggen'),
         ('A4c', 'N0189', 'BuildUVMPkg'),
         ('A5', 'N0097 N0012 N0034 N0207 N0054 N0197 N0222 N0225 N0227 N0234 N0235 N0237 N0238 N0247 N0252 N0253 N2400 N2401', 'MiniAmiq'),
         ('A6', 'N0923', 'BlackBePipeInt'),
         ('B1', 'N0056', 'PreprocTest'), ('B2', 'N0852 N0912 N1137 N1147 N1150 N1155', 'int_types'),
         ('B3', 'N0526 N0954 N0958 N1010 N1011 N1019 N1020', 'SVSwitch'), ('B4a', 'N0025 N0033 N0133 N0263 N0487', 'cfg_func_width_loop'),
         ('B4b', 'N0028 N0552 N0761 N0817', 'struct_param_func_config'), ('B4c', 'N1139', 'Scr1SvTests'),
         ('B5', 'N0083 N0422 N0484 N1149', 'LogicTypespec'),
         ('B6', 'N0067 N0068 N0180 N0158 N0177 N0184 N0188 N0423 N0117 N0120 N0213 N0230 N0232 N0254 N0255 N0256', 'MiniAmiq'),
         ('pA', 'N0003', 'StructParamPatternInitCast'), ('pA2', 'N0943', 'ibex_pmp'), ('pA3', 'N0086 N0087 N0131', 'FuncStructValSimple'),
         ('pA4', 'N0427', 'InterfArrayBind'), ('pA5', 'N0820', 'anon_struct_packed_dim'), ('pA6', 'N0191 N0001', 'OutputSizeWithParameterOfInstanceInitializedByStructMember'),
         ('pA7', 'N0016', 'UnitElabBlock'), ('pA8', 'N0443 N0684', 'arb_idx_cast'), ('pA9', 'N0224 N0228 N0175 N0217 N0220', 'SeqDriver'),
         ('pB', 'N0040', 'InterfaceModPort'), ('pB2', 'N0219', 'ibex_pmp'), ('pB3', 'N0023', 'rsp_gen_minimal'),
         ('pB4', 'N0090 N0448', 'arb_idx_cast'), ('pB5', 'N0853 N1127', 'OutputSizeWithParameterOfInstanceInitializedByStructMember'),
         ('pB6', 'N0011', 'UnitElabBlock'), ('pB7', 'N0738 N0085', 'func_typename_ret'), ('pB8', 'N0133 N0487', 'const_cast_signext'),
         ('pB9', 'N1174', 'HierPathTypespec'), ('pB10', 'N0014', 'anon_struct_packed_dim'), ('pB11', 'N0519 N1117 N1126 N1128 N1134', 'InterfaceStructMemberPort'),
         ('pB12', 'N0563', 'ibex_tracer'), ('pB13', 'N0144 N0327 N0072', 'MiniAmiq')]
P('== F. map 11 section-9 items and pair routes recounted at ddc67d87 (rows = row-modes carrying the cluster; the row = the item\'s target)')
P('| item | clusters | rows 4a65840e -> ddc67d87 (per cluster) | probe 4a65840e -> ddc67d87 | target row status ddc67d87 | converted by |')
P('|---|---|---|---|---|---|')
last = state[STEPS[-1][0]][0]
for it, cl, t in ITEMS:
    per = ' '.join(f"{c} {CI8[c]['rows'] if c in CI8 else '-'}->{CI9[c]['rows'] if c in CI9 else 0}" for c in cl.split())
    pp = ' '.join(f"{CI8[c]['probe_cases'] if c in CI8 else '-'}->{CI9[c]['probe_cases'] if c in CI9 else 0}" for c in cl.split())
    corp = 'uhdm2rtlil' if any(k[0] == 'uhdm2rtlil' and k[2] == t for k in last) else 'surelog'
    st = ' / '.join(f"{m[0]}:{last.get((corp, m, t), ('-', ''))[0]}" for m in ('default', 'testflags'))
    by = ' '.join(sorted({conv[k] for k in conv if k[2] == t})) or '-'
    P(f'| {it} | {cl} | {per} | {pp} | {red(t)} {st} | {by} |')
