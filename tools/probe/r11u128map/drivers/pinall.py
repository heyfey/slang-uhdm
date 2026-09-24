#!/usr/bin/env python3
"""Run pinsite.sh for every pinprep.tsv line (up to 3 ranks each) and name, for
each backtrace frame in src/, the nearest `§ law` at or above the line.
Args: <pinprep.tsv> <debug exporter> <repo src dir> <out file>"""
import sys, subprocess, re, os
tsv, BIN, SRC, OUT = sys.argv[1:5]
here = os.path.dirname(os.path.abspath(__file__))
cache = {}
def law_above(f, line):
    if f not in cache: cache[f] = open(os.path.join(SRC, f), errors='replace').read().splitlines()
    L = cache[f]
    for i in range(min(line, len(L)) - 1, max(0, line - 400), -1):
        m = re.search(r'§ ([A-Za-z][A-Za-z0-9_]+)', L[i])
        if m: return f'§ {m.group(1)} (line {i+1})'
    return '-'
with open(OUT, 'w') as o:
    for l in open(tsv):
        p = l.rstrip('\n').split('\t')
        if len(p) < 7: continue
        k, row, what, ranks = p[0], p[1], p[2], eval(p[3].split('=', 1)[1])
        cwd = p[4].split('=', 1)[1]; mk = p[5].split('=', 1)[1]; args = p[6].split('=', 1)[1].split()
        o.write(f'== {k} {row} {what}\n')
        for r in ranks[:3]:
            bt = subprocess.run([os.path.join(here, 'pinsite.sh'), BIN, mk, r, cwd] + args,
                                capture_output=True, text=True).stdout.splitlines()
            o.write(f'  rank {r}:\n')
            for b in bt[:9]:
                m = re.search(r'at \S*/src/(\w+\.cpp):(\d+)', b)
                extra = f'   [{law_above(m.group(1), int(m.group(2)))}]' if m else ''
                o.write('    ' + re.sub(r'slang_uhdm::UhdmExporter::', '', b)[:150] + extra + '\n')
        o.flush()
