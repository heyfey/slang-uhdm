#!/usr/bin/env python3
# toward.py <golden.uhdm> <P.uhdm> <L.uhdm>: id-stripped multiset dump lines; how many P/L lines golden holds
import sys, subprocess, re, collections, os
D = os.environ.get('UHDM_DUMP', '/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump')
def ms(f):
    out = subprocess.run([D, f], capture_output=True, text=True).stdout
    return collections.Counter(re.sub(r', id:\d+', '', l).rstrip() for l in out.splitlines() if 'uhdm' not in l.lower() or 'vpi' in l)
g, p, l = (ms(x) for x in sys.argv[1:4])
def inter(a, b): return sum((a & b).values())
pg, lg = inter(p, g), inter(l, g)
lost = (p & g) - (l & g); gained = (l & g) - (p & g)
print(f"P={sum(p.values())} L={sum(l.values())} G={sum(g.values())} P&G={pg} L&G={lg} delta={lg-pg} lostTowardGold={sum(lost.values())} gained={sum(gained.values())}")
if len(sys.argv) > 4:
    for k, v in lost.items(): print('  LOST', v, k)
    for k, v in gained.items(): print('  GAIN', v, k)
