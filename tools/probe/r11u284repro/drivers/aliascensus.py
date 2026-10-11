#!/usr/bin/env python3
# r11u284 aliascensus.py <probe sweep workdir> <out>: for every probe case (results/golden_probe.csv), the package-named
# typespecs' own Typedef_alias / Elem references in the golden and in ours (rtsinfo ALIASONLY): role, listing,
# the listing object's parent, the full name.  Fail-closed on $FENCED.
import csv, os, re, subprocess, sys
REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('aliascensus: FENCED unset')
fz = re.compile(r'\b(?:%s)\b' % '|'.join(map(re.escape, FENCED)))
import check_probe as cp
wd, out = sys.argv[1], sys.argv[2]
RT = os.environ.get('RTSINFO', '/tmp/r11u284_bin/rtsinfo')
env = dict(os.environ, ALIASONLY='1')
with open(out, 'w') as f:
    for r in csv.DictReader(open(os.path.join(REPO, 'results/golden_probe.csv'))):
        c = r['case']
        if fz.search(c): continue
        g = cp.golden(c, '/tmp/r11u284_scratch/cls/gw', 300)[0]
        o = os.path.join(wd, c.replace('/', '__') + '.uhdm')
        if not g or not os.path.exists(o): continue
        a = subprocess.run([RT, g, 'x'], capture_output=True, text=True, env=env).stdout.splitlines()
        b = subprocess.run([RT, o, 'x'], capture_output=True, text=True, env=env).stdout.splitlines()
        if not a and not b: continue
        for l in a: f.write(f'{c}\tG\t{r["status"]}\t{l}\n')
        for l in b: f.write(f'{c}\tO\t{r["status"]}\t{l}\n')
