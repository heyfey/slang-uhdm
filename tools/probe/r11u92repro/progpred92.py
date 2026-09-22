#!/usr/bin/env python3
"""r11u92 LAW A MOVER PREDICTOR — read a PRISTINE database and count the
PROGRAM holders that carry a `vpiContAssign` vector.  LAW A's gate returns
before `instSetContAssigns`, and that call is itself guarded by
`if (!cas->empty())`, so a program home with NO cell in the pristine emission
cannot move a byte: the vector was never installed there either.  This is the
a-priori mover prediction, read from the PRISTINE side, before any patched
database is compared.

  usage: progpred92.py <dump-or-uhdm> [...]          (a .uhdm is dumped first)
"""
import re, subprocess, sys, os

DUMP = os.environ.get('DUMP', '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump')


def count(path):
    if path.endswith('.uhdm'):
        txt = subprocess.run([DUMP, path], capture_output=True, text=True).stdout
    else:
        txt = open(path, errors='replace').read()
    stack, hits, progs = [], 0, 0
    for ln in txt.split('\n'):
        m = re.match(r'^(\s*)\\_(\w+):', ln)
        if m:
            ind, kind = len(m.group(1)), m.group(2)
            stack = [(a, b) for a, b in stack if a < ind]
            stack.append((ind, kind))
            if kind == 'program':
                progs += 1
            continue
        f = re.match(r'^(\s*)\|vpiContAssign:', ln)
        if f:
            ind = len(f.group(1))
            for a, b in reversed(stack):
                if ind == a + 2:
                    if b == 'program':
                        hits += 1
                    break
    return progs, hits


for p in sys.argv[1:]:
    pr, hi = count(p)
    print('%-70s program_holders=%d with_contassign=%d' % (p, pr, hi))
