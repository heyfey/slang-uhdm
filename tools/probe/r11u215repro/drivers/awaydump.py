#!/usr/bin/env python3
"""r11u215: order-blind uhdm-dump AWAY census of one database triple (golden, pristine, law): every dump line with the
workdir paths and the object ids normalised, as multisets.  LOST = lines golden and pristine share that the law
database no longer has (a line moved AWAY from golden); GAINED = the reverse.  It sees what the strict record walk
canonicalises (a full name inside a typespec copy prints on the dump line).
usage: awaydump.py <golden.uhdm> <pristine.uhdm> <law.uhdm> [v]"""
import sys, subprocess, collections, re, os
D = os.environ.get('UHDM_DUMP', '/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump')
def lines(u):
    t = subprocess.run([D, u], capture_output=True, text=True, errors='replace').stdout
    c = collections.Counter()
    for l in t.splitlines()[1:]:
        l = re.sub(r'file:[^,]*/', 'file:', l); l = re.sub(r', id:\d+', '', l); l = re.sub(r'/[^ ,)]*/', '', l)
        c[l] += 1
    return c
G, P, L = (lines(u) for u in sys.argv[1:4])
lost = (G & P) - L; gained = (G & L) - P
print(f'dump_lines lost={sum(lost.values())} gained={sum(gained.values())} away_from_golden={sum(((L - G) - (P - G)).values())}')
if len(sys.argv) > 4:
    for k, v in lost.items(): print('  LOST', v, k.strip())
    for k, v in list(gained.items())[:40]: print('  GAIN', v, k.strip())
