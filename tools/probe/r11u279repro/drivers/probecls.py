#!/usr/bin/env python3
# r11u277 probecls.py <probe workdir> <probe csv> <out dir>: the first strict record of every STRICT_NOTEQUAL
# probe case (uhdm-strictcmp --max 1, its database against check_probe's cached golden), one line per case:
# case<TAB>field<TAB>A record<TAB>B record. Probe cases only (tests/probe); fail-closed on $FENCED.
import os, sys, subprocess, csv, re
F = os.environ.get('FENCED', '').split()
assert len(F) == 4, 'FENCED not set'
here = os.path.dirname(os.path.abspath(__file__))
repo = os.path.abspath(os.path.join(here, '../../../..'))
sys.path.insert(0, os.path.join(repo, 'scripts'))
import check_probe as cp
sc = os.environ['STRICT_CMP']; assert os.access(sc, os.X_OK)
wd, pcsv, out = sys.argv[1:4]
os.makedirs(out, exist_ok=True)
fre = re.compile(r'\b(' + '|'.join(map(re.escape, F)) + r')\b')
res = []
for r in csv.DictReader(open(pcsv)):
    if r['status'] != 'STRICT_NOTEQUAL': continue
    rel = r['case']
    if fre.search(rel): continue
    g, _ = cp.golden(rel, out, 60)
    o = os.path.join(wd, rel.replace('/', '__') + '.uhdm')
    p = subprocess.run([sc, '--max', '1', g, o], capture_output=True, text=True)
    lines = p.stdout.splitlines()
    a = b = fld = raw = ''
    for i, l in enumerate(lines):
        if l.startswith('#') and not fld:
            fld = l.split()[1]
        elif l.strip().startswith('A:') and not a: a = l.strip()[3:]
        elif l.strip().startswith('B:') and not b: b = l.strip()[3:]
        elif l.strip().startswith('raw') and not raw: raw = l.strip()
    if not fld: fld = (lines[-1] if lines else '?')
    res.append((rel, fld, a.replace('\t', '|'), b.replace('\t', '|'), raw))
with open(os.path.join(out, 'first.tsv'), 'w') as f:
    for x in res: f.write('\t'.join(x) + '\n')
print(len(res))
