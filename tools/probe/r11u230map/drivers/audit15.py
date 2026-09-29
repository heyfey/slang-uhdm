#!/usr/bin/env python3
"""r11u230map: the prediction audit of map 14 (tools/probe/r11u222map, measured at 551c9751, addendum at 75a564b0,
landed at 4a620bd0) against the landings since: pass 223 (75a564b0, map 14's addendum), map 14 itself (4a620bd0, tools
only), pass 224 (ac0dda58), pass 225 (1a30095a), the verification r11u226 (01dc93ab), the patch-file removal
(a332e45b, e0d6957c, tools and tests only) and the verification r11u229 (97343175, this map's base). (map 14's
audit14b.py re-based; M8 is the PREVIOUS map, map 14.) Conversions are read from the committed baselines at each landing
commit (git show <commit>:results/golden_*.csv), never from a sweep. Map 14's predictions: (a) its fail_list.csv
`clears` (pairs r11u224 / r11u223 optimistic) and `clears_named`, (b) its section-12 greedy lists
(evidence/greedy14.json). The landing laws of every converted test are transcribed from the pass READMEs' verdict
tables (LANDED); their files are read from src by the section sign. The site audit compares those files with map 14's
pin of the row's first cluster and of its first open cluster after the pairs (fail_list.csv -> cluster_index.csv site),
and with its ground override.
Args: <repo> <this map's out dir (cluster_index.csv)>"""
import csv, io, subprocess, sys, re, json, collections, os, glob
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import fenced
REPO, OUT = sys.argv[1:3]
M8 = f'{REPO}/tools/probe/r11u222map'   # the PREVIOUS map (map 14)
FEN = fenced(); red = lambda n: 'FENCED' if n in FEN else n
STEPS = [('551c97519', 'map 14 base'), ('75a564b01', 'pass 223'), ('4a620bd0c', 'map 14'), ('ac0dda58d', 'pass 224'),
         ('1a30095a6', 'pass 225'), ('01dc93ab0', 'r11u226'), ('a332e45b8', 'patch removal'), ('e0d6957cc', 'law index'),
         ('973431753', 'r11u229')]
def at(commit, f):
    return list(csv.DictReader(io.StringIO(subprocess.run(['git', '-C', REPO, 'show', f'{commit}:results/{f}'], capture_output=True, text=True).stdout)))
state = {}
for c, _ in STEPS:
    s = {}
    for corp in ('surelog', 'uhdm2rtlil'):
        for r in at(c, f'golden_{corp}.csv'): s[(corp, r['mode'], r['name'])] = (r['status'], r['strict'])
    state[c] = (s, {r['case']: (r['status'], r['strict']) for r in at(c, 'golden_probe.csv')})
conv = {}; pconv = {}; P = print
P('== A. conversions per landing since map 14 (committed baselines)')
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
 'pass 225': {'InterfArrayBind': 'ifArrElemLitCaFresh225',
              'OutputSizeWithParameterOfInstanceInitializedByStructMember': 'initHierAtRefToken225 initHierCaLhsBareName225 initHierFillKept225'}}
SRC = sorted(glob.glob(f'{REPO}/src/*.cpp') + glob.glob(f'{REPO}/src/*.h'))
_txt = {p: open(p, errors='replace').read() for p in SRC}
def lawfiles(law):
    fs = [os.path.basename(p).rsplit('.', 1)[0] for p, t in _txt.items() if re.search(r'§ ' + law + r'\b', t)]
    fs = [f for f in fs if f != 'EmitHelpers'] or fs
    return fs
FL8 = {(r['corpus'], r['mode'], r['test']): r for r in csv.DictReader(open(f'{M8}/fail_list.csv'))}
CI8 = {r['cluster_id']: r for r in csv.DictReader(open(f'{M8}/cluster_index.csv'))}
predB = {k for k, r in FL8.items() if r['clears'].startswith('yes')}
# map 14 section 6: its credited rows were InterfArrayBind d (pair B, also named) and cfg_func_width_loop d/t (pairs A+B,
# optimistic only): the optimisms are the credited rows its NAMED count did not clear
predN = {k for k, r in FL8.items() if r.get('clears_named', '').startswith('yes')}
OPTI = {k for k, r in FL8.items() if r['clears'].startswith('yes')} - predN
G = json.load(open(f'{M8}/evidence/greedy14.json'))
lists = collections.defaultdict(dict); lclu = collections.defaultdict(dict)
for g, steps in G.items():
    for i, st in enumerate(steps):
        for c in st['add']: lclu[g].setdefault(c, i + 1)
        for r in st['rows']:
            k = tuple(r.split('|')); lists[g][k] = (i + 1, ' + '.join(st['add'][:6]) + (' ...' if len(st['add']) > 6 else ''))
open8 = set(FL8)
P(f'== B. map 14 predicted, on its 551c9751 fail list ({len(open8)} row-modes)')
P(f'   pairs r11u224 / r11u223 optimistic: {len(predB)} row-modes (of which {len(predB & OPTI)} optimistic only, {len(predN)} named)')
for g in G: P(f'   section-12 list {g}: {len(lists[g])} row-modes')
anyp = predB | set().union(*[set(lists[g]) for g in G])
P(f'   predicted by any of them: {len(anyp)}')
by = collections.defaultdict(list)
for k in sorted(open8):
    tag = conv.get(k, 'open')
    pr = ('pairs' + ('(optimism)' if k in OPTI else '') if k in predB else '') + ''.join(f' {g.replace(" ", "")}{lists[g][k][0]}' for g in G if k in lists[g])
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
P(f'   pairs: {len(predB)} predicted, {len(predB & set(conv))} converted; open:', ' '.join(f'{k[0][:3]}/{k[1][0]}/{red(k[2])}' for k in sorted(predB - set(conv))))
P(f'   named only: {len(predN)} predicted, {len(predN & set(conv))} converted')
P('== C. per converted row: predicted by, map 14 first cluster / first open cluster after its pairs and its pin and ground, the landing law files')
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
    pred = 'pairs' + (' (optimism)' if k in OPTI else ' (named)') if k in predB else next((f'list-{g} step {lists[g][k][0]}' for g in G if k in lists[g]), 'not predicted')
    GOV8 = json.load(open(f'{M8}/evidence/ground_override.json'))
    gfc0 = GOV8.get(fc0, '-')
    rows.append(dict(landing=tag, row='/'.join(k), laws=laws, files='+'.join(sorted(lf)), first_cluster=fc0, first_open_after_pairs=fc,
                     pin_mint=mint_of(site0), verdict_first=verdict0, verdict=verdict, predicted=pred, clears=FL8.get(k, {}).get('clears', '')))
    P(f"   {tag:9s} {k[0][:3]}/{k[1][0]}/{red(k[2]):34s} {pred:32s} first={fc0} pin={mint_of(site0):14s} ({verdict0}; override {gfc0}) first-open-after-pairs={fc} ({verdict}) laws={laws} ({'+'.join(sorted(lf))}); map-14 clears={FL8.get(k, {}).get('clears', '')}")
    P(f"             site of {fc0} in map 14: {site0[:260]}")
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
    pa = int(CI8[c]['probe_cases']) if c in CI8 else 0; pb = int(CI9[c]['probe_cases']) if c in CI9 else 0
    a0 = int(CI8[c]['rows']) if c in CI8 else 0
    return a0, b, pa, pb, ('gone' if b == 0 and pb == 0 else 'rows cleared' if b == 0 and a0 > 0 else 'fell' if b < a0 else 'unchanged' if b == a0 else 'grew')
for tag, S in (('map 14 covered (pairs r11u224 / r11u223 optimistic)', B8), ('map 14 section-12 lists', set(L8))):
    fs = collections.Counter(); det = collections.defaultdict(list)
    for c in sorted(S):
        a, b, pa, pb, f = fate(c); fs[f] += 1; det[f].append(f'{c}{"(" + L8[c] + ")" if c in L8 else ""} {a}->{b}')
    P(f'== D. {tag}: {len(S)} clusters (rows at 551c9751 -> 97343175): {dict(fs)}')
    for f, v in det.items(): P(f'     {f}: ' + ' '.join(v[:90]) + (' ...' if len(v) > 90 else ''))
unp = []
for c, r in CI8.items():
    if c in B8 or c in L8: continue
    a, b, pa, pb, f = fate(c)
    if (a > 0 and b < a) or (pa > 0 and pb < int(CI8[c]['probe_cases']) and pb == 0): unp.append((a - b, c, a, b, int(CI8[c]['probe_cases']), pb))
unp.sort(reverse=True)
P(f'== E. clusters map 14 did not route (covered / section 9) whose rows or probe cases cleared or fell: {len(unp)}:', ' '.join(f'{c} rows {a}->{b} probe {p0}->{p1}' for _, c, a, b, p0, p1 in unp[:70]))
json.dump(rows, open(os.path.join(os.path.dirname(OUT.rstrip('/')), 'audit_rows.json'), 'w'), indent=0)
P('== F. map 14 section-12 lists: per list the rows it predicted and their status at 97343175')
last = state[STEPS[-1][0]][0]
for g in G:
    for i, st in enumerate(G[g][:12]):
        rs = ' '.join(f"{r.split('|')[0][:3]}/{r.split('|')[1][0]}/{red(r.split('|')[2])}:{last.get(tuple(r.split('|')), ('-',))[0]}" for r in st['rows'])
        P(f"   {g} step {i+1}: {' + '.join(st['add'][:8])}{' ...' if len(st['add']) > 8 else ''} -> {rs}")
