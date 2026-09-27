#!/usr/bin/env python3
"""obmovers.py <pristine sweep wd> <law sweep wd> <probe_movers.txt> <out.tsv>: for every probe byte mover, the
ORDER-BLIND record distance to golden (uhdm-strictcmp records, depth dropped, multisets: ours-not-in-golden +
golden-not-in-ours) of the pristine and of the law database.  TOWARD = total shrinks, AWAY = grows, SAME = equal.
(A copy of obprobe.py over the mover list instead of the verdict movers.)  Fail-closed on $FENCED."""
import os, re, sys, subprocess, collections
R181 = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../..'))  # (v11u181: repo root from this file)
sys.path.insert(0, R181 + '/scripts')
FEN = os.environ.get('FENCED', '').split()
assert len(FEN) == 4, 'FENCED'
fre = re.compile(r'\b(' + '|'.join(FEN) + r')\b')
import check_probe as cp
P, L, mv, out = sys.argv[1:5]
X = '/tmp/r11u181_bin/uhdm-strictcmp'; T = '/tmp/r11u181_obp'; os.makedirs(T, exist_ok=True)
def recs(g, o):
    subprocess.run([X, '--max', '0', '--dump-a', T + '/a', '--dump-b', T + '/b', g, o], capture_output=True)
    a = collections.Counter('\t'.join(l.split('\t')[1:14]) for l in open(T + '/a', errors='replace'))
    b = collections.Counter('\t'.join(l.split('\t')[1:14]) for l in open(T + '/b', errors='replace'))
    return sum((b - a).values()) + sum((a - b).values())
rows = []; cnt = collections.Counter()
for l in open(mv):
    m = re.match(r'^MOVER (\S+)\.uhdm (\S+)', l)
    if not m or fre.search(m.group(1)): continue
    n = m.group(1) + '.uhdm'
    rel = None
    for cand in [m.group(1).replace('__', '/')]:
        if os.path.isdir(R181 + '/tests/probe/' + cand): rel = cand
    if rel is None: rows.append((m.group(1), '-', '-', 'NOCASE', m.group(2))); continue
    g = os.path.join(cp.cache_dir(rel), 'golden.uhdm')
    dp, dl = recs(g, f'{P}/probe/{n}'), recs(g, f'{L}/probe/{n}')
    v = 'TOWARD' if dl < dp else ('AWAY' if dl > dp else 'SAME')
    cnt[v] += 1
    rows.append((rel, dp, dl, v, m.group(2)))
with open(out, 'w') as f:
    f.write('case\tpristine\tlaw\tdirection\tpredicted\n')
    for r in rows: f.write('\t'.join(str(x) for x in r) + '\n')
print(dict(cnt))
