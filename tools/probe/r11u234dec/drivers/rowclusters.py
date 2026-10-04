#!/usr/bin/env python3
"""rowclusters.py <golden.uhdm> <ours.uhdm> <outprefix> [label]: map 15's analyzer (r11u230map/drivers/analyze.py,
alignment and mode-4 rule unchanged, rekeyed by common.rekey) over one database pair; each facet row is given map
15's cluster id by its key (cluster_index.csv). Writes <outprefix>.jsonl (every row) and prints per cluster:
objects, the first example (golden record # / ours record #, golden / ours value). Requires $STRICTX (source env.sh).
The label is checked against the fence (fail closed)."""
import sys, os, json, subprocess, csv, collections
MAP = os.environ.get('MAP') or sys.exit('source drivers/env.sh')
sys.path.insert(0, MAP); import analyze, common
X = os.environ.get('STRICTX', '')
if not os.access(X, os.X_OK): sys.exit('STRICTX not executable')
g, o, out = sys.argv[1:4]; label = sys.argv[4] if len(sys.argv) > 4 else os.path.basename(out)
F = common.fenced()
if common.is_fenced(g + ' ' + o + ' ' + label, F): sys.exit('fenced: refusing')
a, b, so = out + '.a', out + '.b', out + '.out'
with open(so, 'w') as f:
    subprocess.run([X, '--max', '0', '--dump-a', a, '--dump-b', b, g, o], stdout=f, stderr=subprocess.STDOUT)
if not (os.path.exists(a) and os.path.exists(b)):
    print(f"{label} STAGE1 (no record dumps): " + open(so).read().strip().splitlines()[-1]); sys.exit(0)
r = analyze.analyze('x', 'x', label, a, b, out + '.tmp', so)
idx = {}
for row in csv.DictReader(open(os.path.join(MAP, '..', 'cluster_index.csv'))): idx[row['key']] = row['cluster_id']
C = collections.OrderedDict()
with open(out + '.jsonl', 'w') as f:
    for x in r['rows']:
        k = common.rekey(x); x['key'] = k; x['cid'] = idx.get(k, 'NEW')
        f.write(json.dumps(x) + '\n')
        c = C.setdefault((x['cid'], k), [0, x]); c[0] += x.get('nobj', 1)
print(f"{label} nA={r['nA']} nB={r['nB']} verify={r['verify']['ok']} first={r['verify']['first']} ndiff={r['verify']['ndiff']} clusters={len(C)}")
for (cid, k), (n, x) in sorted(C.items(), key=lambda kv: kv[0][0]):
    print(f"{cid}\t{n}\t{k}\t#{x['ia']}/{x['ib']} {x['type']} '{x['name']}' g={x['golden']} o={x['ours']} | {x['chain']}")
