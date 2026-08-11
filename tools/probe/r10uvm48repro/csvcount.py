#!/usr/bin/env python3
"""r10uvm48 — per-mode STATUS and DUMP tallies of a sweep CSV, so a
`match -> differ` that hides inside an aggregate is visible as a number and not
only as a whole-row diff.  Refuses to print a tally for a file it cannot read as
a CSV with the expected columns (a driver that cannot find its data must not
report perfection).
  usage: csvcount.py <sweep.csv>...
"""
import collections
import csv
import sys

need = {'name', 'mode', 'status', 'dump'}
rc = 0
for f in sys.argv[1:]:
    try:
        rows = list(csv.DictReader(open(f)))
    except OSError as e:
        print('FATAL %s: %s' % (f, e))
        rc = 3
        continue
    if not rows or not need <= set(rows[0]):
        print('FATAL %s: not a sweep CSV (columns=%s)' %
              (f, rows[0].keys() if rows else None))
        rc = 3
        continue
    print('%s rows=%d' % (f, len(rows)))
    for mode in sorted({r['mode'] for r in rows}):
        sub = [r for r in rows if r['mode'] == mode]
        st = collections.Counter(r['status'] for r in sub)
        dm = collections.Counter(r['dump'] for r in sub)
        print('  %-10s n=%d status=%s' % (mode, len(sub), dict(sorted(st.items()))))
        print('  %-10s     dump=%s' % ('', dict(sorted(dm.items()))))
sys.exit(rc)
