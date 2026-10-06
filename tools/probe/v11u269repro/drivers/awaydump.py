#!/usr/bin/env python3
# (v11u269: copied from r11u269repro/drivers)
# (r11u269: copied from r11u267repro/drivers)
# (r11u267: copied from r11u265repro/drivers)
# (r11u265: copied from r11u263repro/drivers)
# (r11u263: copied from r11u261repro/drivers)
# (r11u261: copied from r11u259repro/drivers)
# (r11u259: copied from r11u257repro/drivers)
# (r11u257: copied from r11u248repro/drivers)
# awaydump.py <golden.uhdm> <pristine.uhdm> <law.uhdm>: the order-blind away census for a case-view that stage 1
# rejects (uhdm-strictcmp writes no records then): each database is dumped with $UHDM_DUMP, ids and the case-dir
# paths dropped, and the lines compared as multisets. lost = golden-agreeing lines pristine had and the law lost;
# gained = the reverse; dist = our lines golden lacks. Case dumps only (no corpus path is ever passed here).
import os, re, sys, subprocess, collections
D = os.environ.get('UHDM_DUMP', '')
if not (D and os.access(D, os.X_OK)): sys.exit('awaydump.py: UHDM_DUMP not executable')
def lines(u):
    out = subprocess.run([D, u], capture_output=True, text=True, errors='replace').stdout
    c = collections.Counter()
    for l in out.splitlines():
        l = re.sub(r'id:\d+', 'id:', l)
        l = re.sub(r'file:\S*/', 'file:', l)
        c[l] += 1
    return c
g, p, l = (lines(x) for x in sys.argv[1:4])
lost = (g & p) - l; gained = (g & l) - p
print(f'dist {sum((p - g).values())} -> {sum((l - g).values())} lost={sum(lost.values())} gained={sum(gained.values())}')
if len(sys.argv) > 4:
    for k, v in lost.items(): print('  LOST', v, k)
    for k, v in gained.items(): print('  GAIN', v, k)
