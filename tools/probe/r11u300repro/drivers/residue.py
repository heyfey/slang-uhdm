#!/usr/bin/env python3
# r11u298 (copied from r11u294repro) residue.py <sweep workdir> [max]: the first strict records of every STRICT_NOTEQUAL probe case of a
# sweep (uhdm-strictcmp --max <max> on the case's cached golden, check_probe.golden, against the sweep's
# database).  STRICT_CMP names the comparator; run from anywhere (paths resolve from the repo).
import os, subprocess, sys, csv
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
os.chdir(REPO)
import check_probe as cp
wd = sys.argv[1]; m = sys.argv[2] if len(sys.argv) > 2 else '3'
sc = os.environ.get('STRICT_CMP', os.path.join(REPO, 'build', 'uhdm-strictcmp'))
for r in csv.DictReader(open(wd + '/probe.csv')):
    if r['status'] != 'STRICT_NOTEQUAL':
        continue
    g, _ = cp.golden(r['case'], os.path.join(wd, 'gw'), 300)
    o = wd + '/probe/' + r['case'].replace('/', '__') + '.uhdm'
    out = subprocess.run([sc, '--max', m, g, o], capture_output=True, text=True).stdout
    print('###', r['case'], r['strict']); print(out.rstrip())
