#!/usr/bin/env python3
"""Away census: for each sv-tests row a law fired on and whose status did not
change, the normalised dump line-multiset distance to golden of the control's
database (pristine) and of the law sweep's.  usage: away.py rows.lst out.tsv"""
import sys, os, re, subprocess, collections
from concurrent.futures import ThreadPoolExecutor
D = '/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump'
CTL = '/tmp/intr11u407/svtests/work'; LAW = '/tmp/r11u409_wd/svtests/work'
def golden(row):
    t = open(os.path.join(LAW, row, 'cmds.txt')).read()
    m = re.search(r'cache hit (\S+?)\)', t)
    if m:
        for d, _, fs in os.walk(m.group(1)):
            if 'golden.uhdm' in fs: return os.path.join(d, 'golden.uhdm')
    g = os.path.join(LAW, row, 'slpp_all', 'surelog.uhdm')
    return g if os.path.exists(g) else None
def ms(f):
    out = subprocess.run([D, f], capture_output=True, text=True, timeout=3600).stdout
    c = collections.Counter()
    for l in out.splitlines()[1:]:
        c[re.sub(r'id:\d+,? ?|, file:[^,]*', '', l)] += 1
    return c
def dist(a, b): return sum(((a - b) + (b - a)).values())
def one(row):
    row = row.strip()
    g = golden(row); p = os.path.join(CTL, row, 'slang.uhdm'); l = os.path.join(LAW, row, 'slang.uhdm')
    if not (g and os.path.exists(p) and os.path.exists(l)): return row, 'missing', '', ''
    if open(p, 'rb').read() == open(l, 'rb').read(): return row, 'same-bytes', '', ''
    G = ms(g); a = dist(G, ms(p)); b = dist(G, ms(l))
    return row, ('toward' if b < a else 'same-distance' if a == b else 'AWAY'), a, b
rows = [r for r in open(sys.argv[1]) if r.strip()]
with ThreadPoolExecutor(3) as ex, open(sys.argv[2], 'w') as o:
    for r in ex.map(one, rows):
        o.write('\t'.join(map(str, r)) + '\n'); o.flush()
