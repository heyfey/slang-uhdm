#!/usr/bin/env python3
"""uvmrows.py <sweep workdir> <out dir> [rows...]: for the UVM rows (default: MiniAmiq SeqDriver SimpleUVM Scoreboard
BuildUVMPkg, both modes where the sweep has them) map 15's analyzer (analyze.py over strictcmp_x dumps, rekeyed by
common.rekey) against each row's golden (cmds.txt's golden cache dir): writes <out>/ana.jsonl (one line per row-mode:
test, mode, rows; the input shape of r11u175's uvmcensus.py) and <out>/clusters.tsv (row-mode, map 15 cluster id,
objects, key). Requires $STRICTX (source env.sh). Fail-closed on the fence (no fenced row is opened)."""
import os, sys, re, glob, json, csv, subprocess, collections
MAP = os.environ.get('MAP') or sys.exit('source drivers/env.sh')
sys.path.insert(0, MAP); import analyze, common
X = os.environ.get('STRICTX', '')
if not os.access(X, os.X_OK): sys.exit('STRICTX not executable')
F = common.fenced()
W, OUT = sys.argv[1:3]
ROWS = sys.argv[3:] or ['MiniAmiq', 'SeqDriver', 'SimpleUVM', 'Scoreboard', 'BuildUVMPkg']
os.makedirs(OUT, exist_ok=True)
idx = {r['key']: r['cluster_id'] for r in csv.DictReader(open(os.path.join(MAP, '..', 'cluster_index.csv')))}
ana = open(os.path.join(OUT, 'ana.jsonl'), 'w'); cl = open(os.path.join(OUT, 'clusters.tsv'), 'w')
for t in ROWS:
    if common.is_fenced(t, F): sys.exit('fenced row in list: refusing')
    for m in ('default', 'testflags'):
        d = glob.glob(f'{W}/surelog/{m}/{t}-*')
        if not d or not os.path.exists(d[0] + '/slang.uhdm'): continue
        g = re.search(r'golden cache [a-z]* ([^)]*)', open(d[0] + '/cmds.txt').read())
        gu = glob.glob(g.group(1) + '/*.uhdm')[0]
        p = os.path.join(OUT, f'{t}_{m}')
        with open(p + '.out', 'w') as f:
            subprocess.run([X, '--max', '0', '--dump-a', p + '.a', '--dump-b', p + '.b', gu, d[0] + '/slang.uhdm'],
                           stdout=f, stderr=subprocess.STDOUT)
        if not os.path.exists(p + '.a'):
            print(t, m, 'STAGE1'); continue
        r = analyze.analyze('surelog', m, t, p + '.a', p + '.b', p + '.tmp', p + '.out')
        for x in r['rows']: x['cluster'] = common.rekey(x)
        ana.write(json.dumps(dict(corpus='surelog', mode=m, test=t, rows=r['rows'], nA=r['nA'], nB=r['nB'],
                                  first=r['verify']['first'], ndiff=r['verify']['ndiff'])) + '\n')
        C = collections.Counter()
        for x in r['rows']: C[(idx.get(x['cluster'], 'NEW'), x['cluster'])] += x.get('nobj', 1)
        for (cid, k), n in sorted(C.items()): cl.write(f'{t}/{m}\t{cid}\t{n}\t{k}\n')
        print(t, m, 'clusters=', len(C), 'first=', r['verify']['first'], 'ndiff=', r['verify']['ndiff'], flush=True)
        for s in ('.a', '.b', '.out'): os.unlink(p + s)
