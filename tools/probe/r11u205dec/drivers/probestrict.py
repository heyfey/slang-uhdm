#!/usr/bin/env python3
"""r11u205: strict records of every STRICT_NOTEQUAL probe case of results/golden_probe.csv.
usage: probestrict.py <sweep probe dir (slang dbs, rel with / -> __)> <outdir> [--all]
golden = scripts/check_probe.py cache_dir(rel); ours = <dir>/<rel with / -> __>.uhdm.
Fence: refuses any case whose path names a fenced test (canaudit.sh FENCED= line; fail closed)."""
import os, re, sys, subprocess, csv
from concurrent.futures import ThreadPoolExecutor
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import check_probe as cp
F = None
for l in open(os.path.join(REPO, 'tools/probe/r11u107repro/canaudit.sh')):
    if l.startswith('FENCED='):
        F = re.sub(r'["\']', '', l[len('FENCED='):]).split()
assert F and len(F) == 4, 'fence unreadable: refusing'
def fenced(s): return any(re.search(r'(?<![A-Za-z0-9_])' + re.escape(f) + r'(?![A-Za-z0-9_])', s) for f in F)
sw, out = sys.argv[1], sys.argv[2]
allc = '--all' in sys.argv
SC = os.environ.get('STRICT_CMP', '/tmp/r11u205_bin/uhdm-strictcmp')
os.makedirs(out, exist_ok=True)
rows = list(csv.DictReader(open(os.path.join(REPO, 'results/golden_probe.csv'))))
todo = [r['case'] for r in rows if allc or r['status'] == 'STRICT_NOTEQUAL']
def one(rel):
    if fenced(rel): return rel, 'FENCED'
    g = os.path.join(cp.cache_dir(rel), 'golden.uhdm')
    o = os.path.join(sw, rel.replace('/', '__') + '.uhdm')
    if not (os.path.exists(g) and os.path.exists(o)): return rel, 'MISSING'
    t = os.path.join(out, rel.replace('/', '__'))
    p = subprocess.run([SC, '--max', '100000', g, o], capture_output=True, text=True, timeout=300)
    open(t + '.txt', 'w').write(p.stdout + p.stderr)
    return rel, (p.stdout.strip().splitlines() or ['?'])[-1]
with ThreadPoolExecutor(3) as ex:
    for rel, v in ex.map(one, todo):
        print(rel, v)
