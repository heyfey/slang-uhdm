#!/usr/bin/env python3
"""r10v226 — DIRECTIONAL SCORE, PARENT-QUALIFIED.

v226_dirscore.py keyed on the bare dump line, so context-free labels
(`|vpiParent:`, `|vpiSize:64`, `|vpiActual:`) collided globally and its AWAY
column measured label totals, not regressions (RESUME §9's multiset-collision
trap).  This one keys every line by its ANCESTOR CHAIN of node headers down to
depth `D`, so a `|vpiParent:` under a `ref_obj (work@x.k)` is a different key
from one under a `class_defn`.

Scoring is unchanged: only keys whose count differs pristine-vs-patched are
scored, and each is TOWARD / AWAY / NEUTRAL by whether the patched count sits
closer to golden's than the pristine count did.
usage: v226_dirscore2.py <griddir> [depth]
"""
import sys, os, re
from collections import Counter


def keys(p, depth):
    if not os.path.exists(p):
        return None
    c = Counter()
    stack = []  # (indent, header)
    for raw in open(p, errors='replace'):
        s = raw.rstrip('\n')
        ind = len(s) - len(s.lstrip())
        t = s.strip()
        t = re.sub(r'file:[^,]*', 'file:X', t)
        t = re.sub(r'/[^ ,()]*/', '/X/', t)
        if t.startswith('\\_'):
            while stack and stack[-1][0] >= ind:
                stack.pop()
            ctx = '>'.join(h for _, h in stack[-depth:])
            c['%s>%s' % (ctx, t)] += 1
            stack.append((ind, t))
        else:
            ctx = '>'.join(h for _, h in stack[-depth:])
            c['%s>%s' % (ctx, t)] += 1
    return c


def main():
    root = sys.argv[1]
    depth = int(sys.argv[2]) if len(sys.argv) > 2 else 2
    T = A = N = 0
    for n in sorted(os.listdir(root)):
        a = os.path.join(root, n)
        if not os.path.isdir(a):
            continue
        g = keys(os.path.join(a, 'golden.dump'), depth)
        p = keys(os.path.join(a, 'pris.dump'), depth)
        q = keys(os.path.join(a, 'pat.dump'), depth)
        if not (g and p and q):
            print('ARM %-46s SKIP' % n)
            continue
        t = aw = ne = 0
        away = []
        for L in set(p) | set(q):
            pc, qc, gc = p[L], q[L], g[L]
            if pc == qc:
                continue
            dp, dq = abs(pc - gc), abs(qc - gc)
            if dq < dp:
                t += abs(qc - pc)
            elif dq > dp:
                aw += abs(qc - pc)
                away.append('      AWAY x%d g=%d p=%d q=%d  %s' %
                            (abs(qc - pc), gc, pc, qc, L[-150:]))
            else:
                ne += abs(qc - pc)
        print('ARM %-46s TOWARD %-5d AWAY %-4d NEUTRAL %-4d' % (n, t, aw, ne))
        for x in away[:8]:
            print(x)
        T += t; A += aw; N += ne
    print('TOTAL(depth=%d)  TOWARD %d  AWAY %d  NEUTRAL %d' % (depth, T, A, N))


main()
