#!/usr/bin/env python3
"""r10uvm183 — list the grid cells that DISAGREE with golden identically under
both binaries (the arm's PRE-EXISTING residues).  A grid that only reports what
moved hides what it failed to move, and a residue that this law should have
owned would show up here.  MEASUREMENT ONLY.

Usage: stilloff183.py <arm workdir> [<arm workdir> ...]
"""
import collections
import os
import re
import sys


def load(path):
    kind = collections.defaultdict(collections.Counter)
    inst = collections.defaultdict(collections.Counter)
    if not os.path.exists(path):
        return None, None
    with open(path) as f:
        for line in f:
            p = line.rstrip('\n').split('\t')
            if len(p) < 8 or p[0] != 'FE':
                continue
            key = (p[1], p[2], re.sub(r'#\d+$', '', p[3]))
            kind[key][p[5].split('=', 1)[1]] += 1
            inst[key][re.sub(r'#\d+', '', p[6].split('=', 1)[1])] += 1
    return kind, inst


for w in sys.argv[1:]:
    arm = os.path.basename(w.rstrip('/'))
    for view in ('def', 'elab'):
        gk, gi = load(os.path.join(w, 'cen.g.%s.txt' % view))
        ak, ai = load(os.path.join(w, 'cen.a.%s.txt' % view))
        bk, bi = load(os.path.join(w, 'cen.b.%s.txt' % view))
        if gk is None or ak is None or bk is None:
            continue
        for nm, (g, a, b) in (('KIND', (gk, ak, bk)), ('INST', (gi, ai, bi))):
            for k in sorted(set(g) | set(a) | set(b)):
                cg = g.get(k, collections.Counter())
                ca = a.get(k, collections.Counter())
                cb = b.get(k, collections.Counter())
                if ca == cb and ca != cg:
                    print('%-10s %-5s %-5s STILL-OFF %s %s %s' %
                          (arm, view, nm, k[0], k[1], k[2]))
                    print('      golden %s' % dict(cg))
                    print('      both   %s' % dict(ca))
