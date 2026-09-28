#!/usr/bin/env python3
"""r11u193: judge a list of tests/probe cases with $SLANG_UHDM exactly as scripts/check_probe.py does.
usage: probesub.py <list file of case rels> <workdir> [--jobs N]; prints `case status strict` per case.
Refuses (fail closed) case paths naming a fenced test."""
import os, re, sys
from concurrent.futures import ThreadPoolExecutor
REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import check_probe as cp
fl = [l for l in open(os.path.join(REPO, 'tools/probe/r11u107repro/canaudit.sh')) if l.startswith('FENCED=')]
FENCED = fl[0].split('=', 1)[1].strip().strip('"\'').split() if fl else []
if len(FENCED) != 4:
    sys.exit('probesub: FENCED not 4 names')
fre = re.compile(r'\b(' + '|'.join(map(re.escape, FENCED)) + r')\b')
rels = [r for r in open(sys.argv[1]).read().split() if not fre.search(r)]
wd = sys.argv[2]; os.makedirs(wd, exist_ok=True)
jobs = int(sys.argv[4]) if len(sys.argv) > 4 else 3
with ThreadPoolExecutor(jobs) as ex:
    for rel, st, det, strict, _ in ex.map(lambda r: cp.check(r, wd, 300), rels):
        print(rel, st, strict or det)
