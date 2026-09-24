#!/usr/bin/env python3
"""r11u128 map: clusters, families, coverage by the live pairs, yields,
fullname classes, flip preview. Inputs: corpus.jsonl + probe.jsonl (analyze.py),
probe_law.tsv (case -> laws), the committed scoreboards, the downstream csv,
the r11u122 cluster index (old ids). Args: <work dir> <repo> <out dir>."""
import os as _os, sys as _sys
_sys.path.insert(0, _os.path.dirname(_os.path.abspath(__file__)))
from common import rekey
import json, collections, csv, os, re, sys
W, REPO, OUT = sys.argv[1:4]
os.makedirs(OUT, exist_ok=True)
def load(p):
    return [json.loads(l) for l in open(p)] if os.path.exists(p) else []
RC = load(f'{W}/corpus.jsonl'); RP = load(f'{W}/probe.jsonl')
assert not [r for r in RC + RP if 'error' in r], [r for r in RC + RP if 'error' in r][:3]
LAW = {}
if os.path.exists(f'{W}/probe_law.tsv'):
    for l in open(f'{W}/probe_law.tsv'):
        k, v = l.rstrip('\n').split('\t'); LAW[k] = v
strict = {}; status = {}
for c in ('surelog', 'uhdm2rtlil'):
    for r in csv.DictReader(open(f'{REPO}/results/golden_{c}.csv', newline='')):
        k = (c, r['mode'], r['name']); strict[k] = r['strict'].strip(); status[k] = r['status'].strip()
down = {r['name']: r['verdict'] for r in csv.DictReader(open(f'{REPO}/results/downstream_uhdm2rtlil.csv'))}
old = {}
for r in csv.DictReader(open(f'{REPO}/tools/probe/r11u122map/cluster_index.csv')):
    old[r['key']] = r['cluster_id']
oldfam = {}
for r in csv.DictReader(open(f'{REPO}/tools/probe/r11u122map/family_index.csv')):
    oldfam[r['key']] = r['family_id']

TSISH = lambda t: t.endswith('_typespec') or t in ('range', 'typespec_member')
def family(x, c):
    p = c.split('|'); f = x['facet']; t = x['type']
    if f == 'struct':
        side, how = p[1].split(':'); side = side.replace('-only', '')
        if how == 'absent': return f'STRUCT-ABSENT|{side}|{t}'
        if side == 'golden' and t == 'parameter' and 'under:param_assign' in c: return 'STRUCT-IMPPARAM-CLONE|golden'
        if TSISH(t): return f'STRUCT-TSCOPY|{side}'
        return f'STRUCT-SHARE|{side}|{t}'
    if f in ('depth', 'order'): return 'WALK-DEPTH-ORDER'
    if f == 'fullname':
        if t == 'ref_typespec' or '_typespec' in x['chain']: return 'FULLNAME-IN-TYPESPEC-SUBTREE'
        return f"FULLNAME|{t}|{p[2].split(':')[0]}"
    if f == 'file':
        if '@builtin' in p[2]: return 'FILE-BUILTIN'
        if 'other-file' in p[2]: return 'FILE-OTHER-BUFFER'
        return ('FILE-EMPTY|' if p[2] == 'ours-empty' else 'FILE-EXTRA|') + t
    if f == 'span': return f'SPAN|{t}'
    if f == 'value': return f'VALUE|{t}|{p[2]}'
    if f == 'name': return f'NAME|{t}'
    return c

# Live pairs (the brief's lists, by r11u122 cluster id / family).
PAIR_A = {'C0003', 'C0012', 'C0007', 'C0009', 'C0013', 'C0037', 'C0015', 'C0028', 'C0019', 'C0020', 'C0034', 'C0044', 'C0014'}
PAIR_B = {'C0001', 'C0582', 'C0104'}
SITES = json.load(open(f'{W}/sites.json')) if os.path.exists(f'{W}/sites.json') else {}
def coverage(c, fam):
    o = old.get(c)
    if o in PAIR_A: return f'COVERED r11u124 ({o})'
    if o in PAIR_B: return f'COVERED r11u125 ({o})'
    if fam == 'FULLNAME-IN-TYPESPEC-SUBTREE': return 'COVERED r11u124 (F02 parent policy)'
    if fam == 'FILE-OTHER-BUFFER': return 'COVERED r11u125 (F10)'
    if fam == 'STRUCT-TSCOPY|ours': return 'COVERED r11u125 (F04)'
    if fam == 'FILE-BUILTIN': return 'COVERED r11u125 (builtin package file)'
    s = SITES.get(c, {})
    if s.get('cov'): return s['cov']
    return 'OPEN'

def collect(R, keyf):
    rows = collections.defaultdict(set); fams = collections.defaultdict(set)
    rc = collections.defaultdict(set); obj = collections.Counter(); ro = collections.Counter()
    famOf = collections.defaultdict(collections.Counter); ex = {}
    for r in R:
        k = keyf(r)
        for x in r['rows']:
            c = rekey(x); fm = family(x, c); n = x.get('nobj', 1)
            rows[k].add(c); fams[k].add(fm); rc[c].add(k); obj[c] += n; ro[(k, c)] += n; famOf[c][fm] += 1
            cand = ((r['nA'], len(r['rows'])), k, x)
            if c not in ex or cand[0] < ex[c][0]: ex[c] = cand
    return rows, fams, rc, obj, ro, famOf, ex
ckey = lambda r: (r['corpus'], r['mode'], r['test'])
rowsC, famsC, rcC, objC, roC, famOfC, exC = collect(RC, ckey)
rowsP, famsP, rcP, objP, roP, famOfP, exP = collect(RP, lambda r: r['strict'])  # strict col holds the rel
allc = set(rcC) | set(rcP)
famOf = {c: (famOfC.get(c) or famOfP.get(c)).most_common(1)[0][0] for c in allc}
rank = sorted(allc, key=lambda c: (-len(rcC.get(c, ())), -len(rcP.get(c, ())), -objC.get(c, 0), c))
cid = {c: 'K%04d' % (i + 1) for i, c in enumerate(rank)}
fams = collections.defaultdict(set)
for c in allc: fams[famOf[c]].add(c)
frows = {f: set().union(*[rcC.get(c, set()) for c in cs]) for f, cs in fams.items()}
fprobe = {f: set().union(*[rcP.get(c, set()) for c in cs]) for f, cs in fams.items()}
frank = sorted(fams, key=lambda f: (-len(frows[f]), -len(fprobe[f]), f))
fid = {f: 'G%02d' % (i + 1) for i, f in enumerate(frank)}
cov = {c: coverage(c, famOf[c]) for c in allc}

def yld(fixed, rows): return sum(1 for s in rows.values() if s <= fixed)
def tyld(fixed, rows):
    t = collections.defaultdict(list)
    for k, s in rows.items(): t[(k[0], k[2])].append(s <= fixed)
    return sum(1 for v in t.values() if all(v))
ntests = lambda ks: len({(k[0], k[2]) for k in ks})
json.dump(dict(cid=cid, fid=fid, famOf=famOf, cov=cov), open(f'{W}/ids.json', 'w'))

def ff_of(s): return s.split(':', 1)[1].split('(')[0] if s.startswith('differ:') else s
with open(f'{OUT}/clusters.csv', 'w') as f:
    f.write('test,mode,corpus,first_field,cluster_id,objects\n')
    for k in sorted(rowsC):
        for c in sorted(rowsC[k], key=lambda c: cid[c]):
            f.write(f'{k[2]},{k[1]},{k[0]},{ff_of(strict[k])},{cid[c]},{roC[(k, c)]}\n')
pstrict = {}
if os.path.exists(f'{W}/probe_verdict.tsv'):
    for l in open(f'{W}/probe_verdict.tsv'):
        k, v = l.rstrip('\n').split('\t'); pstrict[k] = v.split('(')[0]
with open(f'{OUT}/probe_clusters.csv', 'w') as f:
    f.write('case,law,first_field,cluster_id,objects\n')
    for k in sorted(rowsP):
        for c in sorted(rowsP[k], key=lambda c: cid[c]):
            f.write(f"{k},{LAW.get(k, '-')},{pstrict.get(k, '')},{cid[c]},{roP[(k, c)]}\n")
def plaws(c, n=3):
    cnt = collections.Counter()
    for k in rcP.get(c, ()):
        for law in LAW.get(k, '-').split(): cnt[law] += 1
    return ' '.join(f'{a}:{b}' for a, b in cnt.most_common(n))
def exs(e):
    k, x = e[1], e[2]
    return f"{'/'.join(k) if isinstance(k, tuple) else k} #{x['ia']}/{x['ib']} {x['type']} {x['name']}"
with open(f'{OUT}/cluster_index.csv', 'w') as f:
    f.write('cluster_id,family_id,rows,rows_surelog,rows_uhdm2rtlil,tests,objects,probe_cases,alone_yield_rows,coverage,r11u122_id,probe_laws,key,example\n')
    for c in rank:
        rs = rcC.get(c, set())
        e = exC.get(c) or exP.get(c)
        f.write(f"{cid[c]},{fid[famOf[c]]},{len(rs)},{sum(1 for k in rs if k[0]=='surelog')},{sum(1 for k in rs if k[0]=='uhdm2rtlil')},"
                f"{ntests(rs)},{objC.get(c,0)},{len(rcP.get(c,()))},{yld({c}, rowsC)},\"{cov[c]}\",{old.get(c,'new')},\"{plaws(c)}\",\"{c}\",\"{exs(e)}\"\n")
with open(f'{OUT}/family_index.csv', 'w') as f:
    f.write('family_id,rows,rows_surelog,rows_uhdm2rtlil,tests,probe_cases,alone_yield_rows,clusters,r11u122_family,key\n')
    for fm in frank:
        rs = frows[fm]
        f.write(f"{fid[fm]},{len(rs)},{sum(1 for k in rs if k[0]=='surelog')},{sum(1 for k in rs if k[0]=='uhdm2rtlil')},{ntests(rs)},{len(fprobe[fm])},"
                f"{yld(fams[fm], rowsC)},{len(fams[fm])},{oldfam.get(fm,'new')},\"{fm}\"\n")

P = print
P('CORPUS rows', len(rowsC), 'tests', ntests(rowsC), 'clusters', len([c for c in allc if c in rcC]), 'families', len([f for f in frank if frows[f]]))
P('PROBE cases NE analysed', len(RP), 'with facets', len(rowsP), 'clusters', len(rcP))
P('== top 60 clusters: id rows sl u2r tests objs probe alone cov old key')
for c in rank[:60]:
    rs = rcC.get(c, set())
    P(cid[c], len(rs), sum(1 for k in rs if k[0]=='surelog'), sum(1 for k in rs if k[0]=='uhdm2rtlil'), ntests(rs), objC.get(c,0), len(rcP.get(c,())), yld({c}, rowsC), cov[c], old.get(c,'new'), c, '|', exs(exC.get(c) or exP.get(c)))
P('== families top 40: id rows tests probe alone nclusters old key')
for fm in frank[:40]:
    P(fid[fm], len(frows[fm]), ntests(frows[fm]), len(fprobe[fm]), yld(fams[fm], rowsC), len(fams[fm]), oldfam.get(fm,'new'), fm)
# coverage totals
covered = {c for c in allc if cov[c] != 'OPEN'}
P('== coverage: clusters covered', len(covered), 'open', len(allc) - len(covered))
for tag in ('r11u124', 'r11u125'):
    s = {c for c in covered if tag in cov[c]}
    P(tag, 'clusters', len(s), 'rows touched', len(set().union(*[rcC.get(c, set()) for c in s])) if s else 0, 'alone yield', yld(s, rowsC), 'tests', tyld(s, rowsC))
P('both pairs landed: yield rows', yld(covered, rowsC), 'tests', tyld(covered, rowsC))
# top 20 OPEN yield table
openr = [c for c in rank if cov[c] == 'OPEN' and c in rcC]
P('== top 20 OPEN clusters (alone / cum on top of both pairs / cum tests)')
cum = set(covered); base = yld(cum, rowsC); tb = tyld(cum, rowsC)
P('base (pairs A+B landed):', base, tb)
for c in openr[:20]:
    cum.add(c)
    rs = rcC[c]
    P(cid[c], len(rs), ntests(rs), yld({c}, rowsC), yld(covered | {c}, rowsC), yld(cum, rowsC), tyld(cum, rowsC), c)
P('== greedy OPEN clusters by marginal yield on top of both pairs')
cum = set(covered)
for i in range(20):
    best = max(openr, key=lambda c: (yld(cum | {c}, rowsC) if c not in cum else -1, len(rcC[c])))
    cum.add(best); P(i + 1, cid[best], yld(cum, rowsC), tyld(cum, rowsC), best)
json.dump(dict(openr=openr[:60]), open(f'{W}/open.json', 'w'))
# OPEN families: a family's open part = its clusters not covered; greedy on top of both pairs.
P('== OPEN families (open part), greedy by marginal yield on top of both pairs')
fo = {f: {c for c in fams[f] if cov[c] == 'OPEN' and c in rcC} for f in frank}
fo = {f: s for f, s in fo.items() if s}
cum = set(covered)
for i in range(25):
    best = max((f for f in fo if not fo[f] <= cum), key=lambda f: (yld(cum | fo[f], rowsC), len(frows[f])))
    cum |= fo[best]
    rs = set().union(*[rcC[c] for c in fo[best]])
    P(i + 1, fid[best], len(rs), ntests(rs), len(fo[best]), yld(cum, rowsC), tyld(cum, rowsC), best)
P('everything:', yld(set(allc), rowsC), tyld(set(allc), rowsC))
# Flip preview: every strict-NE judge-equal row leaves CMP_EQUAL.
with open(f'{OUT}/flip_preview.txt', 'w') as f:
    for c in ('surelog', 'uhdm2rtlil'):
        for m in ('default', 'testflags'):
            eq = [k for k in status if k[0] == c and k[1] == m and status[k] == 'CMP_EQUAL']
            ne = sorted(k[2] for k in eq if strict[k] != 'equal')
            line = f'{c} {m}: judge-equal {len(eq)}, strict-equal {len(eq) - len(ne)}, would leave CMP_EQUAL {len(ne)}'
            if c == 'uhdm2rtlil':
                di = [t for t in ne if down.get(t) == 'IDENTICAL']
                line += f'; of those downstream IDENTICAL {len(di)}, EQUIVALENT {sum(1 for t in ne if down.get(t) == "EQUIVALENT")}, other {sum(1 for t in ne if down.get(t) not in ("IDENTICAL", "EQUIVALENT"))}'
            P(line); f.write(line + '\n' + ' '.join(ne) + '\n')
            if c == 'uhdm2rtlil':
                f.write('  not downstream-IDENTICAL: ' + ' '.join(f'{t}={down.get(t)}' for t in ne if down.get(t) != 'IDENTICAL') + '\n')
        # mode asymmetry
        d = {t for (cc, m, t) in status if cc == c and m == 'default' and status[(cc, m, t)] == 'CMP_EQUAL' and strict[(cc, m, t)] != 'equal'}
        tf = {t for (cc, m, t) in status if cc == c and m == 'testflags' and status[(cc, m, t)] == 'CMP_EQUAL' and strict[(cc, m, t)] != 'equal'}
        deq = {t for (cc, m, t) in status if cc == c and m == 'default' and status[(cc, m, t)] == 'CMP_EQUAL'}
        teq = {t for (cc, m, t) in status if cc == c and m == 'testflags' and status[(cc, m, t)] == 'CMP_EQUAL'}
        line = (f'{c}: tests leaving in some mode {len(d | tf)}; NE in default only {sorted((d - tf) & teq)}; '
                f'NE in testflags only {sorted((tf - d) & deq)}; judged in one mode only (NE) {sorted((d - teq) | (tf - deq))}')
        P(line); f.write(line + '\n')

# Probe view: clusters ranked by probe cases, with the laws whose cases they hit.
P('== probe: clusters by cases (top 30): id cases corpus-rows coverage laws key')
for c in sorted(rcP, key=lambda c: -len(rcP[c]))[:30]:
    P(cid[c], len(rcP[c]), len(rcC.get(c, ())), cov[c], plaws(c), c)
pl = collections.Counter()
for k in rowsP:
    for law in LAW.get(k, '-').split(): pl[law] += 1
P('== probe: laws with the most strict-NE cases (top 25)')
tot = collections.Counter()
for k, v in LAW.items():
    for law in v.split(): tot[law] += 1
for law, n in pl.most_common(25): P(law, n, 'of', tot[law])
P('probe NE cases in clusters fully COVERED:', sum(1 for k, s in rowsP.items() if all(cov[c] != 'OPEN' for c in s)), 'of', len(rowsP))
# REALISTIC yields: a full-name object whose golden name is USE-SITE dependent
# (fullname_classes.py: golden gives more names for the object than ours has
# objects) cannot be fixed by a parent/naming law without a copy per use. Those
# objects form the IDENTITY RESIDUE: a pseudo-cluster no pass covers.
P('== realistic yields (use-site fullname objects split out as RESIDUE)')
rowsR = collections.defaultdict(set)
TSU = json.load(open(f'{W}/tsspan_corpus.json')) if os.path.exists(f'{W}/tsspan_corpus.json') else {}
TSU = {k: set(v) for k, v in TSU.items()}
nres = collections.Counter()
for r in RC:
    k = ckey(r)
    for x in r['rows']:
        c = rekey(x)
        if x['facet'] == 'fullname' and x.get('gnames', 1) > 1 and x.get('onames', 1) < x['gnames']:
            c = 'RESIDUE:' + c; nres['fullname'] += 1
        elif x['facet'] in ('span', 'file') and x['ia'] in TSU.get('|'.join(k), ()):
            c = 'RESIDUE:' + c; nres['typespec-span'] += 1
        rowsR[k].add(c)
P('residue objects:', dict(nres))
P('rows touched by the typespec-span residue:', sum(1 for k, s in rowsR.items() if any(c.startswith('RESIDUE:span') or c.startswith('RESIDUE:file') for c in s)))
covR = {c for c in allc if cov[c] != 'OPEN'}
P('rows touched by RESIDUE:', sum(1 for s in rowsR.values() if any(c.startswith('RESIDUE:') for c in s)),
  'tests', ntests({k for k, s in rowsR.items() if any(c.startswith('RESIDUE:') for c in s)}))
P('both pairs landed (realistic):', yld(covR, rowsR), tyld(covR, rowsR))
for tag in ('r11u124', 'r11u125'):
    s = {c for c in covR if tag in cov[c]}
    P(' ', tag, 'alone (realistic):', yld(s, rowsR), tyld(s, rowsR))
cum = set(covR)
P('greedy OPEN families on top (realistic):')
for i in range(20):
    best = max((f for f in fo if not fo[f] <= cum), key=lambda f: (yld(cum | fo[f], rowsR), len(frows[f])))
    cum |= fo[best]; P(' ', i + 1, fid[best], yld(cum, rowsR), tyld(cum, rowsR), best)
allopen = {c for c in allc}
P('every cluster fixed, residue kept:', yld(allopen, rowsR), tyld(allopen, rowsR), '(of', len(rowsR), 'rows)')
P('residue alone blocks rows:', len(rowsR) - yld(allopen, rowsR))
for c in ('surelog', 'uhdm2rtlil'):
    for m in ('default', 'testflags'):
        sub = {k: v for k, v in rowsR.items() if k[0] == c and k[1] == m}
        P(f'  {c} {m}: NE {len(sub)}; pairs landed {yld(covR, sub)}; everything but residue {yld(allopen, sub)}')
