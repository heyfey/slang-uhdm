#!/usr/bin/env python3
"""r11u165 map (eighth edition; map 7's final.py reduced to the pristine half): clusters keyed as maps 4-7
(analyze.py's key + common.rekey), so a cluster that persists KEEPS its map-7 (r11u156map) id; a cluster new since
map 7 gets the next free N id from N2400 (no id any earlier map used). Writes ids.json (cid, old status, example),
clusters.csv, probe_clusters.csv and a pristine cluster table (pristine_index.csv); coverage, the law cross-section,
the fail lists and the briefs are report8.py's.
Args: <work dir> <repo> <out dir> <sweep dir>.
Inputs in <work dir>: corpus.jsonl, probe.jsonl (analyze.py), probe_law.tsv, probe_verdict.tsv."""
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
M7 = f'{REPO}/tools/probe/r11u156map'   # map 7: its ids persist (same key)
old = {}; m7 = {}; m7p = {}
for r in csv.DictReader(open(f'{M7}/cluster_index.csv')):
    old[r['key']] = r['cluster_id']; m7[r['cluster_id']] = r
for r in csv.DictReader(open(f'{M7}/cluster_index_p147.csv')):
    m7p[r['cluster_id']] = r
USED = {r['cluster_id'] for m in ('r11u132map', 'r11u138map', 'r11u142map', 'r11u150map', 'r11u156map')
        for r in csv.DictReader(open(f'{REPO}/tools/probe/{m}/cluster_index.csv'))}
assert max(u for u in USED if u.startswith('N')) < 'N2400'

def collect(R, keyf):
    rows = collections.defaultdict(set); rc = collections.defaultdict(set); obj = collections.Counter()
    ro = collections.Counter(); ex = {}; first = {}
    for r in R:
        k = keyf(r); best = None
        for x in r['rows']:
            c = rekey(x); n = x.get('nobj', 1)
            rows[k].add(c); rc[c].add(k); obj[c] += n; ro[(k, c)] += n
            cand = ((r['nA'], len(r['rows'])), k, x, r)
            if c not in ex or cand[0] < ex[c][0]: ex[c] = cand
            pos = x['ia'] if x['ia'] >= 0 else x['ib']
            if best is None or pos < best[0]: best = (pos, c)
        if best: first[k] = best[1]
    return rows, rc, obj, ro, ex, first
ckey = lambda r: (r['corpus'], r['mode'], r['test'])
rowsC, rcC, objC, roC, exC, firstC = collect(RC, ckey)
rowsP, rcP, objP, roP, exP, firstP = collect(RP, lambda r: r['strict'])
allc = set(rcC) | set(rcP)
rank = sorted(allc, key=lambda c: (-len(rcC.get(c, ())), -len(rcP.get(c, ())), -objC.get(c, 0), c))
cid = {}; _nx = 2400
for c in rank:
    if c in old: cid[c] = old[c]; continue
    while 'N%04d' % _nx in USED: _nx += 1
    cid[c] = 'N%04d' % _nx; USED.add(cid[c])
ntests = lambda ks: len({(k[0], k[2]) for k in ks})
ff = lambda s: s.split(':', 1)[1].split('(')[0] if s.startswith('differ:') else s
def exs(c):
    e = exC.get(c) or exP.get(c); k, x = e[1], e[2]
    return f"{'/'.join(k) if isinstance(k, tuple) else k} #{x['ia']}/{x['ib']} {x['type']} '{x['name']}' golden={x['golden'][:70]} ours={x['ours'][:70]}"
pstrict = {}
for l in open(f'{W}/probe_verdict.tsv'):
    k, v = l.rstrip('\n').split('\t'); pstrict[k] = v
with open(f'{OUT}/clusters.csv', 'w') as f:
    f.write('test,mode,corpus,first_field,cluster_id,objects,first\n')
    for k in sorted(rowsC):
        for c in sorted(rowsC[k], key=lambda c: cid[c]):
            f.write(f'{k[2]},{k[1]},{k[0]},{ff(strict[k])},{cid[c]},{roC[(k, c)]},{"yes" if firstC.get(k) == c else ""}\n')
with open(f'{OUT}/probe_clusters.csv', 'w') as f:
    f.write('case,law,first_field,cluster_id,objects,first\n')
    for k in sorted(rowsP):
        for c in sorted(rowsP[k], key=lambda c: cid[c]):
            f.write(f"{k},{LAW.get(k, '-')},{pstrict.get(k, '')},{cid[c]},{roP[(k, c)]},{'yes' if firstP.get(k) == c else ''}\n")
def plaws(c, n=3):
    cnt = collections.Counter()
    for k in rcP.get(c, ()):
        for law in LAW.get(k, '-').split(): cnt[law] += 1
    return ' '.join(f'{a}:{b}' for a, b in cnt.most_common(n))
ids = dict(cid=cid, old={c: old.get(c, '') for c in allc}, exs={c: exs(c) for c in allc},
           cov={c: ('map7 ' + m7p[old[c]]['coverage']) if c in old else 'new since map 7' for c in allc},
           m7={old[c]: {k: m7[old[c]][k] for k in ('rows', 'probe_cases', 'coverage', 'site', 'example', 'ground')} | {'rows_p147': m7p[old[c]]['rows_after_law'], 'cov_p147': m7p[old[c]]['coverage'], 'rows_after_pairs_p147': m7p[old[c]]['rows_after_pairs']} for c in allc if c in old},
           firstC={'|'.join(k): cid[c] for k, c in firstC.items()}, firstP={k: cid[c] for k, c in firstP.items()},
           rowsC={'|'.join(k): sorted(cid[c] for c in s) for k, s in rowsC.items()},
           rowsP={k: sorted(cid[c] for c in s) for k, s in rowsP.items()},
           objC={cid[c]: n for c, n in objC.items()}, plaws={cid[c]: plaws(c) for c in allc},
           key={cid[c]: c for c in allc})
json.dump(ids, open(f'{W}/ids.json', 'w'))
q = lambda s: '"' + str(s).replace('"', "'") + '"'
with open(f'{OUT}/pristine_index.csv', 'w') as f:
    f.write('cluster_id,rank,rows,rows_surelog,rows_uhdm2rtlil,tests,objects,probe_cases,first_in_rows,map7_rows_89d599ef,map7_rows_p147,map7_probe,map7_coverage_p147,example_as_map7,key,example\n')
    for i, c in enumerate(rank):
        rs = rcC.get(c, set()); o = old.get(c)
        f.write(','.join(map(str, [cid[c], i + 1, len(rs), sum(1 for k in rs if k[0] == 'surelog'), sum(1 for k in rs if k[0] == 'uhdm2rtlil'),
                ntests(rs), objC.get(c, 0), len(rcP.get(c, ())), sum(1 for k in rs if firstC.get(k) == c),
                m7[o]['rows'] if o else '-', m7p[o]['rows_after_law'] if o else '-', m7[o]['probe_cases'] if o else '-',
                q(m7p[o]['coverage'] if o else 'new'), ('yes' if o and m7[o]['example'] == exs(c) else 'no'), q(c), q(exs(c))])) + '\n')
new = [c for c in rank if c not in old]
gone = [i for k, i in old.items() if k not in allc]
print('CORPUS NE row-modes', len(rowsC), 'tests', ntests(rowsC), 'clusters', len(rcC))
print('PROBE NE cases', len(RP), 'with facets', len(rowsP), 'clusters', len(rcP))
print('clusters', len(allc), 'kept map-7 id', len(allc) - len(new), 'new', len(new), f'({cid[new[0]] if new else "-"}..{cid[new[-1]] if new else "-"})', 'map-7 clusters gone', len(gone))
ver = collections.Counter(r['verify']['ok'] for r in RC + RP)
print('verify (python mode-4 rule vs tool stdout, per row):', dict(ver))
for r in RC + RP:
    if not r['verify']['ok']: print('  VERIFY-MISMATCH', r['corpus'], r['mode'], r['test'], r['verify'])
    s = strict.get(ckey(r)) if r['corpus'] != 'probe' else None
    nobj = lambda s: s.split('(')[1].rstrip(')') if '(' in s else ''
    if s and (ff(s) != r['verify']['tool_first'] or nobj(s) != str(r['verify']['ndiff'])):
        print('  CELL-MISMATCH', ckey(r), s, r['verify'])
print('new clusters with a corpus row:', ' '.join(f'{cid[c]}:{len(rcC[c])}' for c in new if c in rcC))
