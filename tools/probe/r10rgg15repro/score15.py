#!/usr/bin/env python3
"""r10rgg15/score15.py — score one grid cell ORDER-BLIND: {golden, pristine,
patched} joined on the census key, classified FIXED / BROKEN / STILL / MOVED-
STILL-WRONG.  Both the Compare-visible SHAPE and the Rhs SPAN are scored, the
span separately, because `uhdm-cmp` cannot see a span and the DUMP can.

  usage: score15.py <celldir>
"""
import subprocess, sys, os, collections

CEN = os.environ.get('FCENSUS', '/tmp/r10rgg15_fcensus')


def cen(p):
    d = {}
    if not os.path.isfile(p):
        return None
    out = subprocess.run([CEN, p], capture_output=True, text=True,
                         errors='replace').stdout
    for ln in out.splitlines():
        k, _, v = ln.partition('\t')
        f = v.split('\t')
        # field 0 = Compare-visible shape; field 2 = "L:<file>:<l>:<c>"
        loc = f[2] if len(f) > 2 else ''
        loc = ':'.join(loc.split(':')[-2:])     # drop the file, keep l:c
        d.setdefault(k, []).append((f[0], loc))
    return d


def main(d):
    g = cen(os.path.join(d, 'golden.uhdm'))
    p = cen(os.path.join(d, 'ours.uhdm'))
    q = cen(os.path.join(d, 'ours.pat.uhdm'))
    for nm, x in (('golden', g), ('pristine', p), ('patched', q)):
        if x is None:
            print('%s: MISSING %s DATABASE' % (os.path.basename(d), nm))
            return
    c = collections.Counter()
    for k in sorted(set(g) | set(p) | set(q)):
        gg, pp, qq = sorted(g.get(k, [])), sorted(p.get(k, [])), sorted(q.get(k, []))
        for tag, idx in (('shape', 0), ('span', 1)):
            G = [x[idx] for x in gg]
            P = [x[idx] for x in pp]
            Q = [x[idx] for x in qq]
            if P == Q:
                c[(tag, 'STILL-OK' if P == G else 'STILL-WRONG')] += 1
            elif Q == G:
                c[(tag, 'FIXED')] += 1
                print('  FIXED(%s) %s\n     G %s\n     P %s\n     Q %s'
                      % (tag, k, G, P, Q))
            elif P == G:
                c[(tag, 'BROKEN')] += 1
                print('  BROKEN(%s) %s\n     G %s\n     P %s\n     Q %s'
                      % (tag, k, G, P, Q))
            else:
                c[(tag, 'MOVED-STILL-WRONG')] += 1
                print('  MOVED(%s) %s\n     G %s\n     P %s\n     Q %s'
                      % (tag, k, G, P, Q))
    print('%-6s %s' % (os.path.basename(d),
                       ' '.join('%s/%s=%d' % (a, b, n)
                                for (a, b), n in sorted(c.items()))))


if __name__ == '__main__':
    main(sys.argv[1])
