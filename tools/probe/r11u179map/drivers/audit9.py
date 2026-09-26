#!/usr/bin/env python3
"""r11u179: the prediction audit of map 8 (tools/probe/r11u165map, at f2f2d30b) against the landings since:
passes 164, 167, 168, 169, 171, 174 and the verifications r11u170, r11u173, r11u177. Conversions are read from the
committed baselines at each landing commit (git show <commit>:results/golden_*.csv), never from a sweep. Map 8's
predictions: (a) the decodes (measured) + pair B r11u164 optimistic (fail_list.csv clears_after_decodes_and_pair_b),
(b) its section-6 greedy lists (evidence/report.txt section 8: ground A, ground B, joint A+B). The landing laws of
every converted test are transcribed from the pass READMEs' targeted-row tables (LANDED); their files are read
from src by the section sign. The site audit compares those files with map 8's pin of the row's first cluster after
the decodes (fail_list.csv first_cluster_after_decodes -> cluster_index.csv site).
Args: <repo> <map-9 out dir (cluster_index.csv)>"""
import csv, io, subprocess, sys, re, json, collections, os, glob
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import fenced
REPO, OUT = sys.argv[1:3]
M8 = f'{REPO}/tools/probe/r11u165map'
FEN = fenced(); red = lambda n: 'FENCED' if n in FEN else n
STEPS = [('f2f2d30b', 'map 8 base'), ('35ed4056', 'pass 164'), ('2dcbc596', 'r11u170'), ('45b8e774', 'pass 167'),
         ('f34d9d7c', 'pass 168'), ('e3f14d0a', 'r11u173'), ('31739f79', 'pass 169'), ('72fd3061', 'pass 171'),
         ('38d03148', 'pass 174'), ('5e8d08d9', 'r11u177')]
def at(commit, f):
    return list(csv.DictReader(io.StringIO(subprocess.run(['git', '-C', REPO, 'show', f'{commit}:results/{f}'], capture_output=True, text=True).stdout)))
state = {}
for c, _ in STEPS:
    s = {}
    for corp in ('surelog', 'uhdm2rtlil'):
        for r in at(c, f'golden_{corp}.csv'): s[(corp, r['mode'], r['name'])] = (r['status'], r['strict'])
    state[c] = (s, {r['case']: (r['status'], r['strict']) for r in at(c, 'golden_probe.csv')})
conv = {}; pconv = {}; P = print
P('== A. conversions per landing since map 8 (committed baselines)')
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
 'pass 164': {'HighLow': 'rangeQueryFoldUnconverted164', 'GenIfIfaceParamStructField': 'defGenPathSel161',
   'ComplexHierPath': 'defGenPathSel161 genNetDeclAssignLhsShared164', 'iface_param_port_width': 'modportPortViewParamDef164',
   'interface_array': 'modportPortViewParamDef164 portViewParamShared164', 'interface_array_fanout': 'modportPortViewParamDef164 portViewParamShared164',
   'mriscv_bind_sva': 'bindUnresolvedPathNoName164'},
 'pass 167': {'StructParamFieldRange': 'tpAnonStructLastParamUser167 tpAnonStructCopySpanAtKeyword167',
   'StructParamFuncBodyFieldCompare': 'tpAnonStructLastParamUser167 tpAnonStructCopySpanAtKeyword167 evalFuncBodyRhsStampClone167',
   'cva6_struct_param_field': 'tpAnonStructLastParamUser167 tpAnonStructCopySpanAtKeyword167', 'ibex_register_file_ff': 'genProcFoldDeclTsScopeNamed167'},
 'pass 168': {'GenForStructParamBound': 'structParamBoundAtPatternLeaf168 rangeHierPathNoFullName168', 'StructArrayNet': 'hcSelIdxInstName168',
   'YosysMarlann': 'ppBasedLitWsAfter166', 'YosysOldOpen': 'undefKeepsOtherRootMacro168 paramBaseSelTsInstName168', 'ibex_load_store_unit': 'ppOutputLine166'},
 'pass 169': {'pkg_nested_struct_param_width': 'memLeftFormalArgLoc169 memLeftSliceUnlocated169'},
 'pass 171': {'GenerateUnnamed': 'genElseIfGateTermPath171', 'UnionCast': 'boundLitWrittenDigits172 castUnionCloneFile171',
   'YosysBigSimEllip': 'selLhsBareDecRhsShared171 udpFormConcatSwallowSpans171', 'YosysOldOr': 'splitPortTsKeyOnPortDecl171'},
 'pass 174': {'struct_param_field_shift': 'elabParamLeftoverRefUnnamed174 asmRefQualWholeSpanElab174',
   'param_nested_struct_field_width': 'elabParamLeftoverRefUnnamed174 asmRefQualWholeSpanElab174 elabStructMemberOpFoldUnlocated174',
   **{t: 'pkgFnCastTopListing172 tdMoveCarriesFile172 boundLitWrittenDigits172' for t in ('rp32_r5p_alu', 'rp32_r5p_bru', 'rp32_r5p_mdu', 'rp32_r5p_wbu')}}}
SRC = sorted(glob.glob(f'{REPO}/src/*.cpp') + glob.glob(f'{REPO}/src/*.h'))
_txt = {p: open(p, errors='replace').read() for p in SRC}
def lawfiles(law):
    fs = [os.path.basename(p).rsplit('.', 1)[0] for p, t in _txt.items() if re.search(r'§ ' + law + r'\b', t)]
    fs = [f for f in fs if f != 'EmitHelpers'] or fs   # EmitHelpers.h holds the switch block of most ground-A passes
    return fs
# ---- map 8's predictions
FL8 = {(r['corpus'], r['mode'], r['test']): r for r in csv.DictReader(open(f'{M8}/fail_list.csv'))}
CI8 = {r['cluster_id']: r for r in csv.DictReader(open(f'{M8}/cluster_index.csv'))}
predB = {k for k, r in FL8.items() if r['clears_after_decodes_and_pair_b'].startswith('yes')}
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
P(f'== B. map 8 predicted, on its f2f2d30b fail list ({len(open8)} row-modes)')
P(f'   the decodes (measured) + pair B r11u164 optimistic: {len(predB)} row-modes')
for g in ('A', 'B', 'A+B'): P(f'   section-6 list {g}: {len(lists[g])} row-modes')
anyp = predB | set(lists['A']) | set(lists['B']) | set(lists['A+B'])
P(f'   predicted by any of them: {len(anyp)}')
by = collections.defaultdict(list)
for k in sorted(open8):
    tag = conv.get(k, 'open')
    pr = ('dec+pairB' if k in predB else '') + ''.join(f' {g}{lists[g][k][0]}' for g in ('A', 'B', 'A+B') if k in lists[g])
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
P(f'   dec+pairB: {len(predB)} predicted, {len(predB & set(conv))} converted; open:', ' '.join(f'{k[0][:3]}/{k[1][0]}/{red(k[2])}' for k in sorted(predB - set(conv))))
P('== C. per converted row: predicted by, map 8 first cluster (after the decodes) and its pin, the landing law files')
file_of = lambda s: set(re.findall(r'\((\w+)\.(?:cpp|h)', s))
mint_of = lambda s: (re.findall(r'\((\w+)\.(?:cpp|h)', s) or ['?'])[0]
rows = []
for k, tag in sorted(conv.items(), key=lambda x: (x[1], x[0])):
    laws = LANDED.get(tag, {}).get(k[2], '?')
    lf = set(f for law in laws.split() for f in lawfiles(law)) if laws != '?' else set()
    fc = FL8.get(k, {}).get('first_cluster_after_decodes', '-')
    if fc in ('-', ''): fc = FL8.get(k, {}).get('first_cluster', '-')
    site = CI8.get(fc, {}).get('site', '-')
    verdict = ('pin right (mint)' if mint_of(site) in lf else 'pin right (a caller)' if lf & file_of(site) else 'pin misses') if site not in ('-', '') else 'no pin'
    pred = 'dec+pairB' if k in predB else next((f'list-{g} step {lists[g][k][0]} ({lists[g][k][1]})' for g in ('A+B', 'A', 'B') if k in lists[g]), 'not predicted')
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
for tag, S in (('map 8 pair B r11u164 covered (decodes measured + optimistic)', B8), ('map 8 section-6 lists', set(L8))):
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
P(f'== E. clusters map 8 did not route (pair B / section 6) whose rows cleared or fell: {len(unp)}:', ' '.join(f'{c} {a}->{b}' for _, c, a, b in unp[:60]))
json.dump(rows, open(f'{OUT}/../audit_rows.json' if False else os.path.join(os.path.dirname(OUT.rstrip('/')), 'audit_rows.json'), 'w'), indent=0)
