#!/usr/bin/env python3
"""r11u10 — print the AWAY-GOLDEN lines cen10.py counted, so the multiset trap
can be told from a real break.

Usage: away10.py <pristine-dir> <patched-dir>     (two `<test>-<hash>` dirs)
"""
import collections
import os
import re
import subprocess
import sys

DUMP = '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'
IDRE = re.compile(r', id:\d+')


def dump(path, strip):
    r = subprocess.run([DUMP, path], capture_output=True, text=True,
                       errors='replace')
    return collections.Counter(IDRE.sub('', l).replace(strip, '')
                               for l in r.stdout.split('\n'))


def golden_of(d):
    t = open(os.path.join(d, 'cmds.txt'), errors='replace').read()
    g = re.search(r'golden cache hit ([^) \n]*)', t).group(1)
    p = os.path.join(g, 'golden.uhdm')
    if not os.path.isfile(p):
        p = os.path.join(g, [x for x in os.listdir(g)
                             if x.endswith('.uhdm')][0])
    return p


dp, dq = sys.argv[1], sys.argv[2]
gp = golden_of(dq)
G = dump(gp, os.path.dirname(gp))
P = dump(os.path.join(dp, 'slang.uhdm'), dp)
Q = dump(os.path.join(dq, 'slang.uhdm'), dq)
away = (P & G) - (Q & G)
print('AWAY lines (multiset), %d total:' % sum(away.values()))
for l, n in away.most_common():
    print('  x%-4d %s' % (n, l[:150]))
