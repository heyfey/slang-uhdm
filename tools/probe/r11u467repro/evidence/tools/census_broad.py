#!/usr/bin/env python3
# Broad text census: sv-tests rows whose own sources (UVM library excluded,
# `include followed) import at least two distinct packages anywhere.
import os, re, sys, csv
sys.path.insert(0, '/home/heyfey/git-repos/slang-uhdm/scripts/svtests')
import svtests_matrix as sm
SV = '/home/heyfey/git-repos/sv-tests'
fen = [l.strip() for l in open('/tmp/r11u467_fenced.txt') if l.strip()]
IMP = re.compile(r'\bimport\s+(\w+)\s*::')
INC = re.compile(r'`include\s+"([^"]+)"')
def scan(path, inc, seen, pk):
    if path in seen or not os.path.isfile(path) or '/UVM/' in path or 'uvm-2020' in path: return
    seen.add(path)
    t = open(path, errors='replace').read()
    t = re.sub(r'/\*.*?\*/', ' ', t, flags=re.S); t = re.sub(r'//[^\n]*', '', t)
    for m in INC.finditer(t):
        for d in [os.path.dirname(path)] + inc:
            p = os.path.join(d, m.group(1))
            if os.path.isfile(p): scan(p, inc, seen, pk); break
    for m in IMP.finditer(t):
        if m.group(1) not in ('uvm_pkg', 'std'): pk.add(m.group(1))
rows = list(csv.reader(open('/home/heyfey/git-repos/slang-uhdm/results/golden_svtests.csv')))[1:]
out = []
for r in rows:
    case = r[0]
    if any(x in case for x in fen): continue
    p = os.path.join(SV, 'tests', case)
    if not os.path.isfile(p): continue
    prm = sm.parse_metadata(p)
    files = [f if os.path.isabs(f) else os.path.join(SV, f) for f in prm['files']]
    inc = [d if os.path.isabs(d) else os.path.join(SV, d) for d in prm['incdirs']]
    pk = set(); seen = set()
    for f in files: scan(f, inc, seen, pk)
    if len(pk) >= 2: out.append(case)
open(sys.argv[1], 'w').write('\n'.join(out) + '\n')
print(len(out))
