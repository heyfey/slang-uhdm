#!/usr/bin/env python3
"""r10earl39 — join two argts39 censuses on the OBJECT KEY and split the
disagreement into the three groups that matter.

    SURPLUS   key present on both sides, golden ts=0, ours ts=1  -> the head
    MISSING   key present on both sides, golden ts=1, ours ts=0  -> the
              opposite defect; must not grow
    KEY-ONLY  the key itself is absent on one side (a NAME or SPAN difference,
              i.e. a different law) -> reported separately so it can never be
              mistaken for a typespec mover

Key = (kind, span, callee, ancestor-chain, fullname).  Counted as a MULTISET:
the elaborated view repeats the same key once per instance and a per-key count
is what makes "how many objects moved" answerable.

usage: argcmp39.py <golden.argts> <ours.argts>
"""
import collections
import sys


def load(path):
    m = collections.Counter()
    for ln in open(path, errors='replace'):
        f = ln.rstrip('\n')
        # 'kind span ts=N call=... ctx=... name=...'
        parts = f.split(None, 2)
        ts = parts[2].split()[0]
        rest = parts[2][len(ts):].strip()
        key = (parts[0], parts[1], rest)
        m[(key, ts)] += 1
    return m


def main():
    g, o = load(sys.argv[1]), load(sys.argv[2])
    keys = {k for (k, _t) in g} | {k for (k, _t) in o}
    surplus, missing, keyonly = [], [], []
    for k in sorted(keys):
        g0, g1 = g[(k, 'ts=0')], g[(k, 'ts=1')]
        o0, o1 = o[(k, 'ts=0')], o[(k, 'ts=1')]
        if g0 + g1 != o0 + o1:
            keyonly.append((k, g0 + g1, o0 + o1))
            continue
        if g1 == o1:
            continue
        (surplus if o1 > g1 else missing).append((k, g1, o1))
    ns = 0
    print('--- SURPLUS: golden bare, OURS stamps a formal ref_typespec (THE HEAD)')
    for k, g1, o1 in surplus:
        ns += o1 - g1
        print('  +%-3d %-14s %-22s %s' % (o1 - g1, k[0], k[1], k[2]))
    nm = 0
    print('--- MISSING: golden stamps, ours bare (the OPPOSITE defect)')
    for k, g1, o1 in missing:
        nm += g1 - o1
        print('  -%-3d %-14s %-22s %s' % (g1 - o1, k[0], k[1], k[2]))
    print('--- KEY-ONLY: the object key differs (name/span law, NOT this one)')
    nk = 0
    for k, gt, ot in keyonly:
        nk += abs(gt - ot)
        print('  g=%-4d o=%-4d %-14s %-22s %s' % (gt, ot, k[0], k[1], k[2]))
    print()
    print('TOTALS: surplus=%d missing=%d keyonly-objects=%d' % (ns, nm, nk))


if __name__ == '__main__':
    main()
