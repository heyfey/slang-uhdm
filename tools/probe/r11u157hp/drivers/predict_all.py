#!/usr/bin/env python3
"""r11u157: run predict157 over every database of a PRISTINE sweep workdir (both corpora, both modes, and the probe
databases) and write <out>: kind<TAB>mode<TAB>name<TAB>candidates<TAB>laws. Fail-closed fence: the slang-fenced names are
read from RESUME.md (never spelled here); a row whose test is fenced is skipped unread (tests/sweep.sh itself runs the
whole corpus).
Args: <sweep workdir> <predict157 binary> <out.tsv>"""
import os, re, sys, glob, subprocess, collections
from concurrent.futures import ThreadPoolExecutor
wd, bin_, out = sys.argv[1:4]
R = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', 'RESUME.md')
t = open(R).read()
FENCED = set(re.findall(r'`([A-Za-z_][A-Za-z0-9_]*)`', re.search(r'The four slang-fenced tests(.*?)are NEVER dispatched', t, re.S).group(1)))
assert len(FENCED) == 4, 'fence list unreadable: refusing to run'
jobs = []
nfen = 0
for c in ('surelog', 'uhdm2rtlil'):
    for m in ('default', 'testflags'):
        for d in glob.glob(f'{wd}/{c}/{m}/*-*'):
            n = os.path.basename(d).rsplit('-', 1)[0]
            if n in FENCED:
                nfen += 1
                continue   # the gate's own run of a fenced test: never read, never predicted
            db = f'{d}/slang.uhdm'
            if os.path.isfile(db): jobs.append((c, m, n, db))
for db in glob.glob(f'{wd}/probe/*.uhdm'):
    jobs.append(('probe', 'default', os.path.basename(db)[:-5], db))
def run(j):
    c, m, n, db = j
    try:
        p = subprocess.run([bin_, db], capture_output=True, text=True, timeout=900)
    except subprocess.TimeoutExpired:
        return (c, m, n, -1, 'TIMEOUT')
    laws = collections.Counter(l.split('\t')[0] for l in p.stdout.splitlines() if l and not l.startswith('TOTAL'))
    tot = sum(laws.values())
    return (c, m, n, tot, ','.join(f'{k}:{v}' for k, v in sorted(laws.items())))
with ThreadPoolExecutor(3) as ex, open(out, 'w') as f:
    for r in ex.map(run, jobs):
        f.write('\t'.join(map(str, r)) + '\n')
print('databases', len(jobs), 'fenced rows skipped unread', nfen)
