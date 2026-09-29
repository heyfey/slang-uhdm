#!/usr/bin/env python3
"""r11u230 map (fifteenth edition; map 14's final14.py re-based: map 14 = tools/probe/r11u222map is the previous map): clusters keyed as maps 4-9 (analyze.py's key +
common.rekey), so a cluster that persists KEEPS its id (map 10's, else the latest earlier map's for the same key); a
key no map used gets the next free N id above every id maps 3-9 used. Writes ids.json (cid, map-8 columns, example),
clusters.csv, probe_clusters.csv and the pristine cluster table (pristine_index.csv); coverage, the r11u183
cross-section, the fail lists and the briefs are report10.py's.
Args: <work dir> <repo> <out dir> <sweep dir>. Inputs in <work dir>: corpus.jsonl, probe.jsonl (analyze.py),
probe_law.tsv, probe_verdict.tsv."""
import os, sys, json, collections, csv
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
MAPS = ['r11u132map', 'r11u138map', 'r11u142map', 'r11u150map', 'r11u156map', 'r11u165map', 'r11u179map', 'r11u189map', 'r11u197map', 'r11u203map', 'r11u211map', 'r11u222map']
USED_EXTRA = {'N2470'}   # map 13's 62ac216e addendum id (its key was not recorded in cluster_index.csv): never reused
old = {}; USED = set()
for m in MAPS:   # later maps win: map 14 (r11u222map) last
    for r in csv.DictReader(open(f'{REPO}/tools/probe/{m}/cluster_index.csv')):
        old[r['key']] = r['cluster_id']; USED.add(r['cluster_id'])
USED |= USED_EXTRA
# map 13's addendum N2470 = 'BlackBePipeInt d: 4 ours-only dev_addr_width_gp parameter copies elsewhere' (its README section 13);
# the one key of that shape at 896ec643 is exactly that (BlackBePipeInt d, 4 objects, parameter dev_addr_width_gp): it keeps N2470.
old.setdefault('struct|ours-only:elsewhere|parameter|under:ref_obj', 'N2470')
M8 = {r['cluster_id']: r for r in csv.DictReader(open(f'{REPO}/tools/probe/r11u222map/cluster_index.csv'))}   # M8 = the PREVIOUS map (map 14)
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
cid = {}; _nx = int(max(u for u in USED if u.startswith('N'))[1:]) + 1
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
            f.write(f"{k},{LAW.get(k, '-')},{ff(pstrict.get(k, ''))},{cid[c]},{roP[(k, c)]},{'yes' if firstP.get(k) == c else ''}\n")
def plaws(c, n=3):
    cnt = collections.Counter()
    for k in rcP.get(c, ()):
        for law in LAW.get(k, '-').split(): cnt[law] += 1
    return ' '.join(f'{a}:{b}' for a, b in cnt.most_common(n))
m8cols = ('rows', 'probe_cases', 'coverage', 'site', 'example', 'ground', 'rows_after_pairs', 'probe_after_pairs')
ids = dict(cid=cid, old={c: old.get(c, '') for c in allc}, exs={c: exs(c) for c in allc},
           m8={cid[c]: {k: M8[cid[c]][k] for k in m8cols} for c in allc if cid[c] in M8},
           firstC={'|'.join(k): cid[c] for k, c in firstC.items()}, firstP={k: cid[c] for k, c in firstP.items()},
           rowsC={'|'.join(k): sorted(cid[c] for c in s) for k, s in rowsC.items()},
           rowsP={k: sorted(cid[c] for c in s) for k, s in rowsP.items()},
           objC={cid[c]: n for c, n in objC.items()}, objP={cid[c]: n for c, n in objP.items()},
           plaws={cid[c]: plaws(c) for c in allc}, key={cid[c]: c for c in allc})
json.dump(ids, open(f'{W}/ids.json', 'w'))
q = lambda s: '"' + str(s).replace('"', "'") + '"'
with open(f'{OUT}/pristine_index.csv', 'w') as f:
    f.write('cluster_id,rank,rows,rows_surelog,rows_uhdm2rtlil,tests,objects,probe_cases,first_in_rows,map14_rows_551c9751,map14_rows_after_pairs,map14_probe,map14_coverage,example_as_map14,key,example\n')
    for i, c in enumerate(rank):
        rs = rcC.get(c, set()); o = M8.get(cid[c])
        f.write(','.join(map(str, [cid[c], i + 1, len(rs), sum(1 for k in rs if k[0] == 'surelog'), sum(1 for k in rs if k[0] == 'uhdm2rtlil'),
                ntests(rs), objC.get(c, 0), len(rcP.get(c, ())), sum(1 for k in rs if firstC.get(k) == c),
                o['rows'] if o else '-', o['rows_after_pairs'] if o else '-', o['probe_cases'] if o else '-',
                q(o['coverage'] if o else 'new'), ('yes' if o and o['example'] == exs(c) else 'no'), q(c), q(exs(c))])) + '\n')
new = [c for c in rank if cid[c] not in M8]
newid = [c for c in rank if c not in old]
gone = [i for i in M8 if i not in {cid[c] for c in allc}]
print('CORPUS NE row-modes', len(rowsC), 'tests', ntests(rowsC), 'clusters', len(rcC))
print('PROBE NE cases', len(RP), 'with facets', len(rowsP), 'clusters', len(rcP))
print('clusters', len(allc), 'kept map-14 id', len(allc) - len(new), 'not in map 14', len(new), '(of which reused an earlier map id', len(new) - len(newid), '; new ids', len(newid), f'{cid[newid[0]] if newid else "-"}..{cid[newid[-1]] if newid else "-"})', 'map-14 clusters gone', len(gone))
ver = collections.Counter(r['verify']['ok'] for r in RC + RP)
print('verify (python mode-4 rule vs tool stdout, per row):', dict(ver))
for r in RC + RP:
    if not r['verify']['ok']: print('  VERIFY-MISMATCH', r['corpus'], r['mode'], r['test'], r['verify'])
    s = strict.get(ckey(r)) if r['corpus'] != 'probe' else None
    nobj = lambda s: s.split('(')[1].rstrip(')') if '(' in s else ''
    if s and (ff(s) != r['verify']['tool_first'] or nobj(s) != str(r['verify']['ndiff'])):
        print('  CELL-MISMATCH', ckey(r), s, r['verify'])
print('clusters not in map 14 with a corpus row:', ' '.join(f'{cid[c]}:{len(rcC[c])}' for c in new if c in rcC))
