#!/usr/bin/env python3
# probegold.py <probe workdir>: prints "<case rel> <golden.uhdm> <ours.uhdm>" for every probe case (cached goldens,
# the sweep's own databases). Fail-closed on $FENCED (a case path holding a fenced name is skipped unread).
import os, re, sys
REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
fenced = os.environ.get('FENCED', '').split()
if len(fenced) != 4:
    sys.exit('probegold: FENCED unset')
fre = re.compile(r'\b(' + '|'.join(map(re.escape, fenced)) + r')\b')
import check_probe as cp, verify_golden as vg
wd = sys.argv[1]
for rel in cp.cases(None):
    if fre.search(rel):
        continue
    hit = vg.cache_load(cp.cache_dir(rel))
    ours = os.path.join(wd, rel.replace('/', '__') + '.uhdm')
    if hit and hit[1] and os.path.isfile(ours):
        print(rel, hit[1], ours)
