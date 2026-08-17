#!/usr/bin/env python3
"""r10vrgg7/dbcensus.py -- WHOLE-DUMP object census, SECTIONED and DEPTH-KEYED.

  usage: dbcensus.py <dump> [<dump> ...]

Sections a uhdm-dump by the design-level label that owns each line:
  DEF   = under |uhdmallModules:
  ELAB  = under |uhdmtopModules:
  TAIL  = everything else (packages, typespecs, the design node itself)
and prints, per section:
  * total objects
  * per-KIND counts
  * the DEPTH-KEYED identity census: a multiset of (depth, kind) so a subtree
    that MOVED shows up even when the totals happen to agree.
Paths and ids are never read, so no fullname/span enters the comparison.
Two or more dumps print a per-kind and per-(depth,kind) DELTA table.
GUARD: a dump whose section totals are all zero is reported as EMPTY -- an
instrument that reaches nothing must never read as agreement.
"""
import sys, re, collections

OBJ = re.compile(r'^(\s*)(?:\\_)?([a-z_0-9]+): ')


def census(path):
    sec = 'TAIL'
    kinds = collections.defaultdict(collections.Counter)
    dk = collections.defaultdict(collections.Counter)
    tot = collections.Counter()
    for ln in open(path, errors='replace'):
        s = ln.rstrip('\n')
        st = s.lstrip()
        if st.startswith('|uhdmallModules:'):
            sec = 'DEF'
            continue
        if st.startswith('|uhdmtopModules:'):
            sec = 'ELAB'
            continue
        m = OBJ.match(s)
        if not m:
            continue
        depth = len(m.group(1))
        k = m.group(2)
        kinds[sec][k] += 1
        dk[sec][(depth, k)] += 1
        tot[sec] += 1
    return kinds, dk, tot


def main():
    res = {}
    for p in sys.argv[1:]:
        res[p] = census(p)
        k, d, t = res[p]
        print('== %s' % p)
        for s in ('DEF', 'ELAB', 'TAIL'):
            print('   %-5s objects=%d kinds=%d depth-keys=%d' %
                  (s, t[s], len(k[s]), len(d[s])))
        if sum(t.values()) == 0:
            print('   EMPTY -- this dump measured NOTHING')
    ps = sys.argv[1:]
    for q in ps[1:]:
        ka, da, ta = res[ps[0]]
        kb, db, tb = res[q]
        print('== DELTA %s -> %s' % (ps[0], q))
        for s in ('DEF', 'ELAB', 'TAIL'):
            print('   %-5s total %d -> %d (%+d)' % (s, ta[s], tb[s], tb[s] - ta[s]))
            allk = sorted(set(ka[s]) | set(kb[s]))
            rows = [(x, ka[s][x], kb[s][x]) for x in allk if ka[s][x] != kb[s][x]]
            for x, a, b in rows:
                print('       %-18s %6d -> %6d  (%+d)' % (x, a, b, b - a))
            plus = sum(max(0, db[s][x] - da[s][x])
                       for x in set(da[s]) | set(db[s]))
            minus = sum(max(0, da[s][x] - db[s][x])
                        for x in set(da[s]) | set(db[s]))
            print('       depth-keyed: EXTRA-in-B=%d MISSING-in-B=%d' % (plus, minus))


main()
