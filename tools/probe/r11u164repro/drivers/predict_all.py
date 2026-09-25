#!/usr/bin/env python3
"""r11u164 (copy of r11u161gen/drivers/predict_all.py): run predict164 over every database of a PRISTINE sweep workdir (both corpora, both modes, the probe
databases and the downstream lane's slang databases) and write <out>: stage<TAB>mode<TAB>name<TAB>candidates<TAB>laws.
Fail-closed fence: $FENCED (drivers/env.sh, read from RESUME.md, never spelled) must hold four names; a row whose
test is fenced is skipped unread.  Args: <sweep workdir> <predict161 binary> <out.tsv>"""
import os, re, sys, glob, subprocess, collections
from concurrent.futures import ThreadPoolExecutor
wd, bin_, out = sys.argv[1:4]
FENCED = set(os.environ.get('FENCED', '').split())
assert len(FENCED) == 4, 'FENCED unset: refusing to run (source drivers/env.sh)'
jobs, nfen = [], 0
def fenced(n): return any(re.search(rf'\b{re.escape(f)}\b', n) for f in FENCED)
for c in ('surelog', 'uhdm2rtlil'):
    for m in ('default', 'testflags'):
        for d in glob.glob(f'{wd}/{c}/{m}/*-*'):
            n = os.path.basename(d).rsplit('-', 1)[0]
            if fenced(n): nfen += 1; continue
            db = f'{d}/slang.uhdm'
            if os.path.isfile(db): jobs.append((c, m, n, db))
for db in glob.glob(f'{wd}/probe/*.uhdm'):
    n = os.path.basename(db)[:-5]
    if fenced(n): nfen += 1; continue
    jobs.append(('probe', 'default', n, db))
for db in glob.glob(f'{wd}/downstream/*/slang.uhdm'):
    n = os.path.basename(os.path.dirname(db))
    if fenced(n): nfen += 1; continue
    jobs.append(('downstream', '-', n, db))
def run(j):
    c, m, n, db = j
    try: p = subprocess.run([bin_, db], capture_output=True, text=True, timeout=900)
    except subprocess.TimeoutExpired: return (c, m, n, -1, 'TIMEOUT')
    laws = collections.Counter(l.split('\t')[0] for l in p.stdout.splitlines() if l and not l.startswith('TOTAL'))
    return (c, m, n, sum(laws.values()), ','.join(f'{k}:{v}' for k, v in sorted(laws.items())))
with ThreadPoolExecutor(3) as ex, open(out, 'w') as f:
    for r in ex.map(run, jobs): f.write('\t'.join(map(str, r)) + '\n')
print('databases', len(jobs), 'fenced rows skipped unread', nfen)
