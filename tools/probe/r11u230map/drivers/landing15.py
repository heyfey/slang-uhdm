#!/usr/bin/env python3
"""r11u230map: what one landing since map 14 did to the map (README section 3). Compares two analyze.py outputs by
cluster KEY (analyze.py's key + common.rekey, the key the ids follow): BEFORE = the landing-off state (its switches on
this map's HEAD binary: the HEAD analysis with every database the state sweep moved re-analyzed, statejobs.py +
analyze.py, merged here) and AFTER = the HEAD analysis. Prints: row-modes and probe cases converted / entered /
changed, clusters gone, new, fell, grew (rows and probe cases). (map 14's landing220.py re-based.)
Args: <HEAD work dir> <state dir (corpus_moved.jsonl, probe_moved.jsonl)> <ids.json> <map-14 cluster_index.csv> <label>"""
import sys, os, json, collections, csv
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import rekey, fenced
AFT, ST, IDS, M13 = sys.argv[1:5]; LABEL = sys.argv[5] if len(sys.argv) > 5 else 'landing'
FEN = fenced(); red = lambda n: 'FENCED' if n in FEN else n
cid = json.load(open(IDS))['cid']
m13 = {r['key']: r['cluster_id'] for r in csv.DictReader(open(M13))}
def name(k): return cid.get(k) or m13.get(k) or ('key:' + k)
def load(d):
    rows = {}; cases = {}
    for f, dst, kf in (('corpus.jsonl', rows, lambda r: (r['corpus'], r['mode'], r['test'])), ('probe.jsonl', cases, lambda r: r['strict'])):
        for l in open(os.path.join(d, f)):
            r = json.loads(l); dst[kf(r)] = ({rekey(x) for x in r['rows']}, r.get('strict', ''), collections.Counter(rekey(x) for x in r['rows']))
    return rows, cases
R1, P1 = load(AFT)
def statemerge(head_dir, st):
    rows = {}; cases = {}
    for f, mv, dst, kf in (('corpus.jsonl', 'corpus_moved.jsonl', rows, lambda r: (r['corpus'], r['mode'], r['test'])),
                           ('probe.jsonl', 'probe_moved.jsonl', cases, lambda r: r['strict'])):
        moved = {}
        for l in open(os.path.join(st, mv)):
            r = json.loads(l); moved[kf(r)] = r
        for l in open(os.path.join(head_dir, f)):
            r = json.loads(l)
            if kf(r) in moved: continue
            dst[kf(r)] = ({rekey(x) for x in r['rows']}, r.get('strict', ''), collections.Counter(rekey(x) for x in r['rows']))
        for k, r in moved.items():
            dst[k] = ({rekey(x) for x in r['rows']}, r.get('strict', ''), collections.Counter(rekey(x) for x in r['rows']))
    return rows, cases
R0, P0 = statemerge(AFT, ST)
rk = lambda k: f'{k[0][:3]}/{k[1][0]}/{red(k[2])}'
P = print
conv = sorted(set(R0) - set(R1)); ent = sorted(set(R1) - set(R0))
pconv = sorted(set(P0) - set(P1)); pent = sorted(set(P1) - set(P0))
P(f'== {LABEL} landed: corpus STRICT_NOTEQUAL row-modes {len(R0)} -> {len(R1)} ({len(conv)} converted, {len(ent)} entered); probe {len(P0)} -> {len(P1)} ({len(pconv)} converted, {len(pent)} entered)')
P('   converted:', ' '.join(rk(k) for k in conv) or '-')
P('   entered:', ' '.join(rk(k) for k in ent) or '-')
P('   probe converted:', ' '.join(pconv) or '-')
P('   probe entered:', ' '.join(pent) or '-')
chg = [k for k in R1 if k in R0 and R0[k][1] != R1[k][1]]
P(f'   row-modes whose strict cell changed: {len(chg)}:', '; '.join(f'{rk(k)} {R0[k][1]} -> {R1[k][1]}' for k in sorted(chg)))
def inv(RR):
    d = collections.defaultdict(set); o = collections.Counter()
    for k, (s, _, c) in RR.items():
        for x in s: d[x].add(k)
        o.update(c)
    return d, o
rc0, o0 = inv(R0); rc1, o1 = inv(R1); pc0, po0 = inv(P0); pc1, po1 = inv(P1)
K0 = set(rc0) | set(pc0); K1 = set(rc1) | set(pc1)
gone = sorted(K0 - K1, key=lambda c: (-len(rc0.get(c, ())), -len(pc0.get(c, ())), c))
new = sorted(K1 - K0, key=lambda c: (-len(rc1.get(c, ())), -len(pc1.get(c, ())), c))
P(f'   clusters (keys) {len(K0)} -> {len(K1)}: gone {len(gone)}, new {len(new)}')
P('   gone (rows/probe before):', '; '.join(f'{name(c)} {len(rc0.get(c, ()))}/{len(pc0.get(c, ()))}' for c in gone[:60]), '...' if len(gone) > 60 else '')
P('   gone with a corpus row:', '; '.join(f'{name(c)} rows {len(rc0[c])} [{" ".join(rk(k) for k in sorted(rc0[c]))}] `{c}`' for c in gone if rc0.get(c)))
P('   new (rows/probe after):', '; '.join(f'{name(c)} {len(rc1.get(c, ()))}/{len(pc1.get(c, ()))} `{c}`' for c in new[:30]))
both = K0 & K1
fell = sorted((c for c in both if len(rc1.get(c, ())) < len(rc0.get(c, ()))), key=lambda c: c)
grew = sorted((c for c in both if len(rc1.get(c, ())) > len(rc0.get(c, ()))), key=lambda c: c)
pfell = [c for c in both if len(pc1.get(c, ())) < len(pc0.get(c, ()))]
pgrew = [c for c in both if len(pc1.get(c, ())) > len(pc0.get(c, ()))]
P('   fell (rows):', '; '.join(f'{name(c)} {len(rc0[c])}->{len(rc1.get(c, ()))}' for c in fell) or '-')
P('   grew (rows):', '; '.join(f'{name(c)} {len(rc0.get(c, ()))}->{len(rc1[c])}' for c in grew) or '-')
P(f'   probe: {len(pfell)} clusters fell, {len(pgrew)} grew:', '; '.join(f'{name(c)} {len(pc0[c])}->{len(pc1.get(c, ()))}' for c in sorted(pfell, key=lambda c: len(pc1.get(c, ())) - len(pc0[c]))[:20]),
  '| grew:', '; '.join(f'{name(c)} {len(pc0.get(c, ()))}->{len(pc1[c])}' for c in pgrew[:20]))
# differing objects per moved row-mode, before and after
P('   differing objects (analyzer facet rows) per row-mode, before -> after:')
for k in sorted(k for k in set(R0) | set(R1) if (R0.get(k) or [None])[0:3] != (R1.get(k) or [None])[0:3]):
    a = sum(R0[k][2].values()) if k in R0 else 0; b = sum(R1[k][2].values()) if k in R1 else 0
    P(f'     {rk(k):55s} {a:6d} -> {b:6d}   clusters {len(R0[k][0]) if k in R0 else 0} -> {len(R1[k][0]) if k in R1 else 0}')
