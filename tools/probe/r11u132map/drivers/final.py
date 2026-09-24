#!/usr/bin/env python3
"""r11u132 map: clusters (N####, keyed as r11u128map's K#### so every cluster
carries its old id), coverage by the landed passes (r11u124/r11u125: a cluster
still present is their RESIDUE, OPEN) and the live pairs (r11u131 = pair A,
r11u130 = pair B, by the brief's r11u128 K ids), sites, yields, the flip fail
list. Args: <work dir> <repo> <out dir> <sweep dir>.
Inputs in <work dir>: corpus.jsonl, probe.jsonl (analyze.py), probe_law.tsv,
probe_verdict.tsv, sites.json (cluster key -> site, from pins.txt / decodes)."""
import os, sys, json, collections, csv, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import rekey
W, REPO, OUT, SW = sys.argv[1:5]
os.makedirs(OUT, exist_ok=True)
load = lambda p: [json.loads(l) for l in open(p)] if os.path.exists(p) else []
RC = load(f'{W}/corpus.jsonl'); RP = load(f'{W}/probe.jsonl')
err = [r for r in RC + RP if 'error' in r]
assert not err, err[:3]
LAW = {}
for l in open(f'{W}/probe_law.tsv'):
    k, v = l.rstrip('\n').split('\t'); LAW[k] = v
strict = {}; status = {}
for c in ('surelog', 'uhdm2rtlil'):
    for r in csv.DictReader(open(f'{SW}/{c}.csv', newline='')):
        k = (c, r['mode'], r['name']); strict[k] = (r.get('strict') or '').strip(); status[k] = r['status'].strip()
down = {r['name']: r['verdict'] for r in csv.DictReader(open(f'{REPO}/results/downstream_uhdm2rtlil.csv'))}
M128 = f'{REPO}/tools/probe/r11u128map'
old = {}; oldcov = {}
for r in csv.DictReader(open(f'{M128}/cluster_index.csv')):
    old[r['key']] = r['cluster_id']; oldcov[r['cluster_id']] = r['coverage']

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

# The live pairs, by the brief's r11u128map K ids.
PAIR_A = {'K0017', 'K0080', 'K0044', 'K0045', 'K0043', 'K0027', 'K0036', 'K0056', 'K0120', 'K0200', 'K0025', 'K0060',
          'K0035', 'K0050', 'K0051', 'K0054', 'K0055', 'K0062', 'K0064', 'K0076', 'K0047', 'K0099'}
PAIR_B = {'K0028', 'K0058', 'K0053', 'K0048', 'K0070', 'K0074', 'K0024', 'K0052', 'K0034', 'K0067', 'K0085', 'K0049', 'K0057'}
SITES = json.load(open(f'{W}/sites.json')) if os.path.exists(f'{W}/sites.json') else {}
def coverage(c):
    o = old.get(c)
    if o in PAIR_A: return f'COVERED r11u131 ({o})'
    if o in PAIR_B: return f'COVERED r11u130 ({o})'
    oc = oldcov.get(o, '')
    if oc.startswith('COVERED'):
        return 'OPEN (residue of landed ' + oc.split()[1] + ')'
    return 'OPEN' if o else 'OPEN (new since r11u128map)'
iscov = lambda s: s.startswith('COVERED')

def collect(R, keyf):
    rows = collections.defaultdict(set); rc = collections.defaultdict(set); obj = collections.Counter()
    ro = collections.Counter(); famOf = collections.defaultdict(collections.Counter); ex = {}; first = {}
    for r in R:
        k = keyf(r); best = None
        for x in r['rows']:
            c = rekey(x); n = x.get('nobj', 1)
            rows[k].add(c); rc[c].add(k); obj[c] += n; ro[(k, c)] += n; famOf[c][family(x, c)] += 1
            cand = ((r['nA'], len(r['rows'])), k, x, r)
            if c not in ex or cand[0] < ex[c][0]: ex[c] = cand
            pos = x['ia'] if x['ia'] >= 0 else x['ib']
            if best is None or pos < best[0]: best = (pos, c)
        if best: first[k] = best[1]
    return rows, rc, obj, ro, famOf, ex, first
ckey = lambda r: (r['corpus'], r['mode'], r['test'])
rowsC, rcC, objC, roC, famOfC, exC, firstC = collect(RC, ckey)
rowsP, rcP, objP, roP, famOfP, exP, firstP = collect(RP, lambda r: r['strict'])
allc = set(rcC) | set(rcP)
famOf = {c: (famOfC.get(c) or famOfP.get(c)).most_common(1)[0][0] for c in allc}
rank = sorted(allc, key=lambda c: (-len(rcC.get(c, ())), -len(rcP.get(c, ())), -objC.get(c, 0), c))
cid = {c: 'N%04d' % (i + 1) for i, c in enumerate(rank)}
cov = {c: coverage(c) for c in allc}
fams = collections.defaultdict(set)
for c in allc: fams[famOf[c]].add(c)
frows = {f: set().union(*[rcC.get(c, set()) for c in cs]) for f, cs in fams.items()}
fprobe = {f: set().union(*[rcP.get(c, set()) for c in cs]) for f, cs in fams.items()}
frank = sorted(fams, key=lambda f: (-len(frows[f]), -len(fprobe[f]), f))
fid = {f: 'H%02d' % (i + 1) for i, f in enumerate(frank)}
def site(c):
    s = SITES.get(c) or SITES.get(cid[c]) or SITES.get(old.get(c, '-'))
    return s or '-'
json.dump(dict(cid=cid, fid=fid, famOf=famOf, cov=cov, old={c: old.get(c, '') for c in allc}), open(f'{W}/ids.json', 'w'))

def yld(fixed, rows): return sum(1 for s in rows.values() if s <= fixed)
def tyld(fixed, rows):
    t = collections.defaultdict(list)
    for k, s in rows.items(): t[(k[0], k[2])].append(s <= fixed)
    return sum(1 for v in t.values() if all(v))
ntests = lambda ks: len({(k[0], k[2]) for k in ks})
ff = lambda s: s.split(':', 1)[1].split('(')[0] if s.startswith('differ:') else s
nobj = lambda s: s.split('(')[1].rstrip(')') if '(' in s else ''

with open(f'{OUT}/clusters.csv', 'w') as f:
    f.write('test,mode,corpus,first_field,cluster_id,objects\n')
    for k in sorted(rowsC):
        for c in sorted(rowsC[k], key=lambda c: cid[c]):
            f.write(f'{k[2]},{k[1]},{k[0]},{ff(strict[k])},{cid[c]},{roC[(k, c)]}\n')
pstrict = {}
for l in open(f'{W}/probe_verdict.tsv'):
    k, v = l.rstrip('\n').split('\t'); pstrict[k] = v
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
def exs(c):
    e = exC.get(c) or exP.get(c); k, x = e[1], e[2]
    return f"{'/'.join(k) if isinstance(k, tuple) else k} #{x['ia']}/{x['ib']} {x['type']} '{x['name']}' golden={x['golden'][:70]} ours={x['ours'][:70]}"
q = lambda s: '"' + str(s).replace('"', "'") + '"'
with open(f'{OUT}/cluster_index.csv', 'w') as f:
    f.write('cluster_id,family_id,rows,rows_surelog,rows_uhdm2rtlil,tests,objects,probe_cases,alone_yield_rows,first_in_rows,coverage,r11u128_id,site,probe_laws,key,example\n')
    for c in rank:
        rs = rcC.get(c, set())
        f.write(','.join(map(str, [cid[c], fid[famOf[c]], len(rs), sum(1 for k in rs if k[0] == 'surelog'),
                sum(1 for k in rs if k[0] == 'uhdm2rtlil'), ntests(rs), objC.get(c, 0), len(rcP.get(c, ())),
                yld({c}, rowsC), sum(1 for k in rs if firstC.get(k) == c), q(cov[c]), old.get(c, 'new'), q(site(c)),
                q(plaws(c)), q(c), q(exs(c))])) + '\n')
with open(f'{OUT}/family_index.csv', 'w') as f:
    f.write('family_id,rows,rows_surelog,rows_uhdm2rtlil,tests,probe_cases,alone_yield_rows,clusters,open_clusters,key\n')
    for fm in frank:
        rs = frows[fm]
        f.write(f"{fid[fm]},{len(rs)},{sum(1 for k in rs if k[0]=='surelog')},{sum(1 for k in rs if k[0]=='uhdm2rtlil')},{ntests(rs)},"
                f"{len(fprobe[fm])},{yld(fams[fm], rowsC)},{len(fams[fm])},{sum(1 for c in fams[fm] if not iscov(cov[c]))},{q(fm)}\n")

covA = {c for c in allc if 'r11u131' in cov[c]}; covB = {c for c in allc if 'r11u130' in cov[c]}; covAB = covA | covB
# The fail list: every judge-equal row-mode not strict-equal, its first cluster and site, and whether the pairs clear it.
with open(f'{OUT}/fail_list.csv', 'w') as f:
    f.write('corpus,test,mode,strict,first_cluster,first_cluster_coverage,first_site,clusters,open_clusters,clears_with_pairs,downstream\n')
    for k in sorted(set(k for k in status if status[k] == 'CMP_EQUAL' and strict[k] not in ('', 'equal'))):
        s = rowsC.get(k, set()); fc = firstC.get(k)
        f.write(','.join(map(str, [k[0], k[2], k[1], strict[k], cid.get(fc, '?'), q(cov.get(fc, '?')), q(site(fc) if fc else '-'),
                len(s), sum(1 for c in s if not iscov(cov[c])), ('A+B' if s <= covAB else '') + (' A' if s <= covA else '') + (' B' if s <= covB else ''),
                down.get(k[2], '') if k[0] == 'uhdm2rtlil' else ''])) + '\n')
with open(f'{OUT}/probe_fail_list.csv', 'w') as f:
    f.write('case,law,strict,first_cluster,first_cluster_coverage,clusters,open_clusters,clears_with_pairs\n')
    for k in sorted(rowsP):
        s = rowsP[k]; fc = firstP.get(k)
        f.write(','.join(map(str, [k, q(LAW.get(k, '-')), pstrict.get(k, ''), cid.get(fc, '?'), q(cov.get(fc, '?')), len(s),
                sum(1 for c in s if not iscov(cov[c])), 'A+B' if s <= covAB else ''])) + '\n')

P = print
P('CORPUS NE row-modes analysed', len(rowsC), 'tests', ntests(rowsC), 'clusters', len(rcC), 'families', sum(1 for f in frank if frows[f]))
P('PROBE NE cases analysed', len(RP), 'with facets', len(rowsP), 'clusters', len(rcP))
ver = collections.Counter(r['verify']['ok'] for r in RC + RP)
P('verify (python mode-4 rule vs tool stdout, per row):', dict(ver))
for r in RC + RP:
    if not r['verify']['ok']: P('  VERIFY-MISMATCH', r['corpus'], r['mode'], r['test'], r['verify'])
    s = strict.get(ckey(r)) if r['corpus'] != 'probe' else None
    if s and (ff(s) != r['verify']['tool_first'] or nobj(s) != str(r['verify']['ndiff'])):
        P('  CELL-MISMATCH', ckey(r), s, r['verify'])
P('== pairs: clusters / rows touched / alone yield rows (tests)')
for tag, S in (('r11u131 (A)', covA), ('r11u130 (B)', covB), ('both', covAB)):
    touched = set().union(*[rcC.get(c, set()) for c in S]) if S else set()
    P(tag, len(S), len(touched), yld(S, rowsC), tyld(S, rowsC))
for c_ in ('surelog', 'uhdm2rtlil'):
    for m in ('default', 'testflags'):
        sub = {k: v for k, v in rowsC.items() if k[0] == c_ and k[1] == m}
        P(f'  {c_} {m}: NE {len(sub)}; A {yld(covA, sub)}; B {yld(covB, sub)}; A+B {yld(covAB, sub)}; after pairs {len(sub) - yld(covAB, sub)}')
subP = rowsP
P('  probe: NE', len(subP), 'A', yld(covA, subP), 'B', yld(covB, subP), 'A+B', yld(covAB, subP))
P('== top 60 clusters: id rows sl u2r tests objs probe alone first cov old key | site | example')
for c in rank[:60]:
    rs = rcC.get(c, set())
    P(cid[c], len(rs), sum(1 for k in rs if k[0] == 'surelog'), sum(1 for k in rs if k[0] == 'uhdm2rtlil'), ntests(rs), objC.get(c, 0),
      len(rcP.get(c, ())), yld({c}, rowsC), sum(1 for k in rs if firstC.get(k) == c), cov[c], old.get(c, 'new'), c, '|', site(c), '|', exs(c))
openr = [c for c in rank if not iscov(cov[c]) and c in rcC]
P('== OPEN clusters by rows (top 80): id rows tests probe first alone +pairs key')
for c in openr[:80]:
    rs = rcC[c]
    P(cid[c], len(rs), ntests(rs), len(rcP.get(c, ())), sum(1 for k in rs if firstC.get(k) == c), yld({c}, rowsC),
      yld(covAB | {c}, rowsC) - yld(covAB, rowsC), cov[c], old.get(c, 'new'), c, '|', site(c))
P('== greedy OPEN clusters by marginal yield on top of both pairs (base', yld(covAB, rowsC), tyld(covAB, rowsC), ')')
cum = set(covAB)
for i in range(30):
    best = max((c for c in openr if c not in cum), key=lambda c: (yld(cum | {c}, rowsC), len(rcC[c])))
    cum.add(best); P(i + 1, cid[best], yld(cum, rowsC), tyld(cum, rowsC), old.get(best, 'new'), best)
fo = {f: {c for c in fams[f] if not iscov(cov[c]) and c in rcC} for f in frank}
fo = {f: s for f, s in fo.items() if s}
P('== OPEN families, greedy by marginal yield on top of both pairs: step fam rows tests nclusters cum-rows cum-tests key')
cum = set(covAB)
for i in range(25):
    cand = [f for f in fo if not fo[f] <= cum]
    if not cand: break
    best = max(cand, key=lambda f: (yld(cum | fo[f], rowsC), len(frows[f])))
    cum |= fo[best]; rs = set().union(*[rcC[c] for c in fo[best]])
    P(i + 1, fid[best], len(rs), ntests(rs), len(fo[best]), yld(cum, rowsC), tyld(cum, rowsC), best)
P('everything:', yld(set(allc), rowsC), tyld(set(allc), rowsC))
P('== first clusters of the fail list (row-modes whose FIRST differing object is in the cluster), top 40')
fcnt = collections.Counter(firstC.values())
for c, n in fcnt.most_common(40): P(cid[c], n, cov[c], c, '|', site(c))
P('== probe: clusters by cases (top 30)')
for c in sorted(rcP, key=lambda c: -len(rcP[c]))[:30]:
    P(cid[c], len(rcP[c]), len(rcC.get(c, ())), cov[c], old.get(c, 'new'), plaws(c), c)
pl = collections.Counter(); tot = collections.Counter()
for k in rowsP:
    for law in LAW.get(k, '-').split(): pl[law] += 1
for k, v in LAW.items():
    for law in v.split(): tot[law] += 1
P('== probe: laws with the most strict-NE cases (top 25)')
for law, n in pl.most_common(25): P(law, n, 'of', tot[law])
