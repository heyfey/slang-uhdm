#!/usr/bin/env python3
"""r10v163 — score ONE adversarial arm view, cell by cell.

Reads three ct163cen censuses (golden, pristine, patched) of the SAME arm and
joins them on the HOLDER VARIABLE NAME, which every cell in these arms spells
uniquely (`s01_...`, `t14_...`, `n13_...`).  Joining on the name rather than on
the span key is deliberate: the span is exactly what §53/§163 move, so a
span-keyed join would refuse to pair the cells under measurement.

Payload compared = (nparam, params) as a MULTISET per name — golden repeats a
key once per elaborated copy and a dict-keyed join would drop those rows.

Verdicts, per cell:
  HELD-RIGHT    pristine == golden == patched
  TO-GOLDEN     pristine != golden, patched == golden
  MOVED-WRONG   pristine == golden, patched != golden      <-- a REGRESSION
  RESHAPE       pristine != patched, neither == golden
  STILL-WRONG   pristine == patched != golden
  ABSENT-BOTH   no row on either side
Exit code 1 if any MOVED-WRONG.
"""
import re
import sys
from collections import defaultdict

def load(path):
    rows = defaultdict(list)
    with open(path) as fh:
        for line in fh:
            line = line.rstrip('\n')
            if not line.startswith('CELL '):
                continue
            fields = [f.strip() for f in line[5:].split(' | ')]
            key = fields[0]
            holder = key.split('|')[-1].split('@')[0]
            d = {}
            for f in fields[1:]:
                if '=' in f:
                    k, _, v = f.partition('=')
                    d[k] = v
            rows[holder].append((d.get('nparam'), d.get('params', ''),
                                 d.get('npa'), d.get('holder', '')))
    return {k: sorted(v) for k, v in rows.items()}


def main():
    g, o, q = (load(p) for p in sys.argv[1:4])
    tag = sys.argv[4] if len(sys.argv) > 4 else ''
    names = sorted(set(g) | set(o) | set(q))
    counts = defaultdict(int)
    bad = 0
    for n in names:
        gv, ov, qv = g.get(n), o.get(n), q.get(n)
        if gv == ov == qv:
            v = 'HELD-RIGHT' if gv is not None else 'ABSENT-BOTH'
        elif ov != gv and qv == gv:
            v = 'TO-GOLDEN'
        elif ov == gv and qv != gv:
            v = 'MOVED-WRONG'
            bad += 1
        elif ov == qv:
            v = 'STILL-WRONG'
        else:
            v = 'RESHAPE'
        counts[v] += 1
        if v != 'HELD-RIGHT':
            print('%-12s %-34s G=%s  P=%s  Q=%s' % (v, n, gv, ov, qv))
    print('-- %s %s' % (tag, ' '.join('%s=%d' % (k, counts[k]) for k in sorted(counts))))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
