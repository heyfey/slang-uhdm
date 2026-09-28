#!/usr/bin/env python3
"""fixjudge.py <fixcases.txt>: per case-mode of fixcases.sh, whether the fix binary moves the law binary's bytes, and
for each mover the strict verdicts, the order-blind uhdm-dump distance to golden (grid.py's dump(): ids and paths
stripped) and the golden lines the fix loses / gains; OFF-MISMATCH when R11V194_OFF=1 does not restore the law's bytes."""
import sys, glob, collections, os
D = os.path.dirname(os.path.abspath(__file__))
src = open(f'{D}/grid.py').read().split('def main():')[0]
exec(src.replace("if len(FENCED) != 4: sys.exit('grid.py: source drivers/env.sh first')", ""))
tot = collections.Counter()
for l in open(sys.argv[1]):
    a, b, c = [x.strip() for x in l.split('||')]
    on = a.split(); rel = on[0]; mo = on[-1]; fx = b.split(); mf = fx[-1]; off = c.split()[-1]
    tot['case-modes'] += 1
    if off != mo: print('OFF-MISMATCH', rel); tot['off-mismatch'] += 1
    if mo == mf: continue
    w = GW + '/' + rel; gs = glob.glob(w + '/gold_*/golden.uhdm')
    if not gs or 'SLANG_FAIL' in a: print('MOVED-NODB', rel, '(no database on either binary)'); continue
    dg = dump(gs[0]); do = dump(w + '/on.uhdm'); df = dump(w + '/fix.uhdm')
    lost = sum(((dg & do) - (dg & df)).values()); gain = sum(((dg & df) - (dg & do)).values())
    tot['movers'] += 1; tot['lost'] += lost
    print('MOVER', rel, on[4], '->', fx[1], 'dist', dist(dg, do), '->', dist(dg, df), 'golden-lines lost', lost, 'gained', gain)
print(dict(tot))
