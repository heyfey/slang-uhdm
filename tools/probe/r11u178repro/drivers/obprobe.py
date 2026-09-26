#!/usr/bin/env python3
"""obprobe.py (r11u178 copy of r11u175uvm/drivers/obprobe.py) <pristine sweep wd> <law sweep wd> <law sweep log> <out.tsv>: for every probe CHANGE and CONVERSION
line of the law sweep's probe stage, the ORDER-BLIND record distance to golden (strictcmp_x records, depth
dropped, multisets: ours-not-in-golden + golden-not-in-ours) of the pristine and of the law database.
TOWARD = total shrinks, AWAY = total grows, SAME = equal.  Fail-closed on $FENCED."""
import os, re, sys, subprocess, collections
sys.path.insert(0, '/tmp/wt_r11u178/scripts')
FEN = os.environ.get('FENCED', '').split()
assert len(FEN) == 4, 'FENCED'
fre = re.compile(r'\b(' + '|'.join(FEN) + r')\b')
import check_probe as cp
P, L, log, out = sys.argv[1:5]
X = '/tmp/r11u178_bin/uhdm-strictcmp'; T = '/tmp/r11u178_obp'; os.makedirs(T, exist_ok=True)
def recs(g, o):
    subprocess.run([X, '--max', '0', '--dump-a', T + '/a', '--dump-b', T + '/b', g, o], capture_output=True)
    a = collections.Counter('\t'.join(l.split('\t')[1:14]) for l in open(T + '/a', errors='replace'))
    b = collections.Counter('\t'.join(l.split('\t')[1:14]) for l in open(T + '/b', errors='replace'))
    return sum((b - a).values()) + sum((a - b).values())
rows = []
for l in open(log):
    m = re.match(r'^(CHANGE|CONVERSION) (\S+) (.*)$', l.rstrip())
    if not m or fre.search(m.group(2)): continue
    rel = m.group(2)
    if not os.path.isdir('/tmp/wt_r11u178/tests/probe/' + rel): continue
    g = os.path.join(cp.cache_dir(rel), 'golden.uhdm')
    n = rel.replace('/', '__') + '.uhdm'
    dp, dl = recs(g, f'{P}/probe/{n}'), recs(g, f'{L}/probe/{n}')
    v = 'TOWARD' if dl < dp else ('AWAY' if dl > dp else 'SAME')
    rows.append((m.group(1), rel, dp, dl, v, m.group(3)))
with open(out, 'w') as f:
    for r in rows: f.write('\t'.join(map(str, r)) + '\n')
c = collections.Counter((r[0], r[4]) for r in rows)
print(sorted(c.items()))
