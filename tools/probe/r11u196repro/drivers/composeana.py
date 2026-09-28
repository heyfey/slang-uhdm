#!/usr/bin/env python3
"""r11u196: read compose.sh output; for each (pristine state, law state) pair of the same switch set, the mover set
(cases whose bytes differ); prints whether the law's mover set is the same in every switch state (additivity at the
byte level) and the OFF-switch check.  usage: composeana.py <compose.txt> <pris> <law> <offstate>"""
import sys
f, P, L, OFF = sys.argv[1:5]
rows = [l.split() for l in open(f) if l.strip()]
def st(r):
    return {x.rsplit('=', 1)[0]: x.rsplit('=', 1)[1] for x in r[1:]}
keys = [k for k in st(rows[0]) if k.startswith(P)]
sets = {}
for k in keys:
    lk = L + k[len(P):]
    sets[k] = {r[0] for r in rows if st(r)[k] != st(r)[lk]}
    print('%-45s movers %d' % (k + ' -> ' + lk, len(sets[k])))
base = sets[P]
print('mover set identical in every switch state:', all(s == base for s in sets.values()))
for k, s in sets.items():
    if s != base: print('  differs in', k, sorted(s ^ base))
off = [r[0] for r in rows if st(r)[OFF] != st(r)[P]]
print('%s vs %s: differ on %d %s' % (OFF, P, len(off), off))
bad = [r[0] + ':' + k for r in rows for k, v in st(r).items() if v.split('/')[1] not in ('0', '4')]
print('rc not 0/4:', bad)
print('movers:', ' '.join(sorted(base)))
