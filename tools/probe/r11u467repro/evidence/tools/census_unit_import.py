#!/usr/bin/env python3
# Text census: sv-tests rows whose own sources (UVM library excluded, `include
# followed through the incdirs) hold a FILE-SCOPE import (outside every
# module/interface/program/package/class/checker/config body).  Candidates
# for § unitCopyOwnTsEveryPath467's traced census.
import os, re, sys, csv
sys.path.insert(0, '/home/heyfey/git-repos/slang-uhdm/scripts/svtests')
import svtests_matrix as sm
SV = '/home/heyfey/git-repos/sv-tests'
fen = [l.strip() for l in open('/tmp/r11u467_fenced.txt') if l.strip()]
OPEN = re.compile(r'^\s*(?:(?:virtual|static|automatic|extern|local|protected|pure|interface)\s+)*\b(module|macromodule|interface|program|package|class|checker|config)\b')
CLOSE = re.compile(r'\bend(module|interface|program|package|class|checker|config)\b')
IMP = re.compile(r'^\s*import\s+\w+\s*::')
INC = re.compile(r'`include\s+"([^"]+)"')
def strip(t):
    t = re.sub(r'/\*.*?\*/', ' ', t, flags=re.S)
    return re.sub(r'//[^\n]*', '', t)
def scan(path, incdirs, seen, depth):
    if path in seen or not os.path.isfile(path) or '/UVM/' in path or 'uvm-2020' in path:
        return depth, False
    seen.add(path)
    hit = False
    for line in strip(open(path, errors='replace').read()).split('\n'):
        for m in INC.finditer(line):
            for d in [os.path.dirname(path)] + incdirs:
                p = os.path.join(d, m.group(1))
                if os.path.isfile(p):
                    depth, h = scan(p, incdirs, seen, depth); hit = hit or h; break
        if depth == 0 and IMP.match(line):
            hit = True
        if OPEN.match(line) and not re.match(r'^\s*interface\s+class', line) or re.match(r'^\s*(virtual\s+)?interface\s+class\b|^\s*(virtual\s+)?class\b', line):
            if not re.search(r'\btypedef\b', line):
                depth += 1
        depth -= len(CLOSE.findall(line))
        if depth < 0: depth = 0
    return depth, hit
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
    seen = set(); hit = False
    for f in files:
        _, h = scan(f, inc, seen, 0); hit = hit or h
    if hit: out.append(case)
open(sys.argv[1], 'w').write('\n'.join(out) + '\n')
print(len(rows), 'rows', len(out), 'candidates')
