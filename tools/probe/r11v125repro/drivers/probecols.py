#!/usr/bin/env python3
# probecols.py wdA wdB : per-probe-case strict verdict for two sweeps, classified
import sys, os, re, glob, collections
sys.path.insert(0, '/tmp/wt_v11u125pris/scripts')
import check_probe as cp, verify_golden as vg
from concurrent.futures import ThreadPoolExecutor
A, B = sys.argv[1], sys.argv[2]
rels = sorted(os.path.relpath(os.path.dirname(p), '/tmp/wt_v11u125pris/tests/probe') for p in glob.glob('/tmp/wt_v11u125pris/tests/probe/**/dut.sv', recursive=True))
def one(rel):
    hit = vg.cache_load(cp.cache_dir(rel)); g = hit[1]
    f = rel.replace('/', '__') + '.uhdm'
    return rel, vg.strict_verdict(g, os.path.join(A, 'probe', f), 300), vg.strict_verdict(g, os.path.join(B, 'probe', f), 300)
def parse(s):
    m = re.match(r'differ:(\w+)\((\d+)\)', s)
    return ('equal', 0) if s == 'equal' else ((m.group(1), int(m.group(2))) if m else (s, -1))
c = collections.Counter(); bad = []
with ThreadPoolExecutor(6) as ex:
    for rel, a, b in ex.map(one, rels):
        if a == b: c['same'] += 1; continue
        pa, pb = parse(a), parse(b)
        if pb[0] == 'equal': k = 'turned_equal'
        elif pa[0] == 'equal': k = 'WORSE'
        elif pa[0] == pb[0]: k = 'fewer' if pb[1] < pa[1] else 'MORE'
        else: k = 'moved_fewer' if pb[1] < pa[1] else ('moved_SAME' if pb[1] == pa[1] else 'moved_MORE')
        c[k] += 1
        if k not in ('turned_equal', 'fewer', 'moved_fewer'): bad.append((k, rel, a, b))
print(len(rels), dict(c))
for x in bad: print(*x)
