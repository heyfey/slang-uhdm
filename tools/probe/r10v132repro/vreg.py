#!/usr/bin/env python3
"""REGRESSION check: rows the PRISTINE matched golden on that the PATCHED lost."""
import sys, subprocess, importlib.util
spec = importlib.util.spec_from_file_location('vs', '/tmp/v132_scratch/vscore132.py')
import re
from collections import Counter
OBJ = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?, ?(.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')
def parse(path):
    raw = open(path, errors='replace').read().split('\n')
    lines = []
    for ln in raw:
        if OBJ.match(ln) or FLD.match(ln) or not lines: lines.append(ln)
        else: lines[-1] = lines[-1] + ' ' + ln.strip()
    c = Counter(); cur = None
    for ln in lines:
        m = OBJ.match(ln)
        if m:
            kind, name, rest = m.group(2), m.group(3) or '', m.group(4)
            stub = (cur == 'vpiParent'); cur = None
            if stub: continue
            sm = re.search(r'line:(\d+:\d+), endln:(\d+:\d+)', rest)
            span = (sm.group(1)+'-'+sm.group(2)) if sm else ''
            c['%s|%s|%s' % (kind, name, span)] += 1
            continue
        f = FLD.match(ln)
        if f: cur = f.group(2)
    return c
g, p, q = parse(sys.argv[1]), parse(sys.argv[2]), parse(sys.argv[3])
lost = (g & p) - (g & q)
gained = (g & q) - (g & p)
print('REGRESSED(pris-matched-golden, pat-lost)=%d  IMPROVED=%d' % (sum(lost.values()), sum(gained.values())))
for k in sorted(lost): print('  LOST %dx %s' % (lost[k], k))
