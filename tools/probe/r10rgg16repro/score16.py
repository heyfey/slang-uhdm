#!/usr/bin/env python3
"""r10rgg16/score16.py — score one grid cell ORDER-BLIND on the interface_inst
census: {golden, pristine, patched} joined on (view, interface_inst full path),
classified FIXED / BROKEN / STILL / MOVED-STILL-WRONG.

The scored payload is the whole `PV=/par=/pa=/mp=/var=/PK=/GK=` tuple, so a
change that fixed `pa` by breaking `par` cannot read as a fix.

  usage: score16.py <celldir>
"""
import subprocess, sys, os, collections

CEN = os.environ.get('PVCENSUS', '/tmp/r10rgg16_pvcensus')


def cen(p):
    if not os.path.isfile(p):
        return None
    out = subprocess.run([CEN, p], capture_output=True, text=True,
                         errors='replace').stdout
    d = {}
    for ln in out.splitlines():
        f = ln.split('\t')
        if len(f) < 10:
            continue
        d[(f[0], f[1])] = tuple(f[2:])
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
    detail = []
    for k in sorted(set(g) | set(p) | set(q)):
        gg, pp, qq = g.get(k), p.get(k), q.get(k)
        if pp == gg and qq == gg:
            c['STILL-RIGHT'] += 1
        elif pp != gg and qq == gg:
            c['FIXED'] += 1
            detail.append(('FIXED', k, pp, qq))
        elif pp == gg and qq != gg:
            c['BROKEN'] += 1
            detail.append(('BROKEN', k, pp, qq))
        elif pp == qq:
            c['STILL-WRONG'] += 1
            detail.append(('STILL-WRONG(ours/gold)', k, pp, gg))
        else:
            c['MOVED-STILL-WRONG'] += 1
            detail.append(('MOVED-STILL-WRONG', k, pp, qq))
    print('%s: %s' % (os.path.basename(d),
                      ' '.join('%s=%d' % (k, c[k]) for k in sorted(c))))
    for t, k, a, b in detail:
        lab = ('ours', 'gold') if t.startswith('STILL-WRONG') else ('was ', 'now ')
        print('    %-22s %s %s\n        %s %s\n        %s %s'
              % (t, k[0], k[1], lab[0], a, lab[1], b))


if __name__ == '__main__':
    for a in sys.argv[1:]:
        main(a)
