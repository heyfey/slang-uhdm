#!/usr/bin/env python3
# r11u287 probecls287.py (copied from r11u285repro/drivers/probecls285.py) <probe workdir> <probe csv> <out dir>: for every STRICT_NOTEQUAL probe case, the first strict
# record (uhdm-strictcmp --max 1 against check_probe's cached golden) with its walk path on golden's side (the kinds
# and names of its ancestors), one line per case: case<TAB>field<TAB>count<TAB>A record<TAB>B record<TAB>path<TAB>raw.
# Probe cases only (tests/probe); fail-closed on $FENCED.
import os, sys, subprocess, csv, re, tempfile
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
def path(recf, idx):
    recs = [l.rstrip('\n').split('\t') for l in open(recf)]
    if idx < 1 or idx > len(recs): return ''
    i = idx - 1; d = int(recs[i][0]); out = []
    for j in range(i - 1, -1, -1):
        if int(recs[j][0]) < d:
            out.append(recs[j][1] + ':' + recs[j][2]); d = int(recs[j][0])
            if d <= 1: break
    return ' > '.join(reversed(out))
res = []
td = tempfile.mkdtemp(prefix='r11u287_pc_', dir='/tmp')
for r in csv.DictReader(open(pcsv)):
    if r['status'] != 'STRICT_NOTEQUAL': continue
    rel = r['case']
    if fre.search(rel): continue
    g, _ = cp.golden(rel, out, 60)
    o = os.path.join(wd, rel.replace('/', '__') + '.uhdm')
    da, db = os.path.join(td, 'a'), os.path.join(td, 'b')
    p = subprocess.run([sc, '--max', '1', '--dump-a', da, '--dump-b', db, g, o], capture_output=True, text=True)
    lines = p.stdout.splitlines()
    a = b = fld = raw = ''; idx = 0
    for l in lines:
        if l.startswith('#') and not fld:
            fld = l.split()[1]; idx = int(l.split()[0][1:])
        elif l.strip().startswith('A:') and not a: a = l.strip()[3:]
        elif l.strip().startswith('B:') and not b: b = l.strip()[3:]
        elif l.strip().startswith('raw') and not raw: raw = l.strip()
    if not fld: fld = (lines[-1] if lines else '?')
    pa = path(da, idx) if idx and os.path.exists(da) else ''
    res.append((rel, fld, r['detail'], a.replace('\t', '|'), b.replace('\t', '|'), pa, raw))
with open(os.path.join(out, 'first.tsv'), 'w') as f:
    for x in res: f.write('\t'.join(x) + '\n')
print(len(res))
