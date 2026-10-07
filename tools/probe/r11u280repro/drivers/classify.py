#!/usr/bin/env python3
# (r11u280: copied from r11u278repro/drivers)
# r11u266 classify.py <probe sweep workdir> <outdir>: for every STRICT_NOTEQUAL case of results/golden_probe.csv,
# uhdm-strictcmp --max 1 with record dumps against check_probe's cached golden; prints one line per case with the
# first differing record of each side. Fail-closed on $FENCED (a case path holding a fenced name by word is refused).
import csv, os, re, subprocess, sys
REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('classify: FENCED unset')
fz = re.compile(r'\b(?:%s)\b' % '|'.join(map(re.escape, FENCED)))
import check_probe as cp
wd, od = sys.argv[1], sys.argv[2]; os.makedirs(od, exist_ok=True)
SC = os.environ['STRICT_CMP']
for r in csv.DictReader(open(os.path.join(REPO, 'results/golden_probe.csv'))):
    if r['status'] != 'STRICT_NOTEQUAL': continue
    c = r['case']
    if fz.search(c): print(c, 'FENCED-REFUSED'); continue
    g = cp.golden(c, os.path.join(od, 'gw'), 300)[0]
    o = os.path.join(wd, c.replace('/', '__') + '.uhdm')
    k = os.path.join(od, c.replace('/', '__'))
    p = subprocess.run([SC, '--max', '3', '--dump-a', k + '.a', '--dump-b', k + '.b', g, o], capture_output=True, text=True)
    open(k + '.out', 'w').write(p.stdout + p.stderr)
    print(c, r['strict'], '|', ' || '.join(l for l in (p.stdout + p.stderr).splitlines()[:8]).replace('\t', ' ')[:600])
