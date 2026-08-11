#!/usr/bin/env python3
"""r10uvm52repro/csvdiff.py — diff a sweep CSV against the COMMITTED baseline,
WHOLE ROW (status AND dump), and print the status/dump histograms of both sides.

The baselines (results/gate_uhdm2rtlil.csv, results/golden_surelog.csv) are read
ONLY.  `wc -l` on them counts the HEADER, so the row counts printed here come
from the parsed dict, never from wc.

  usage: csvdiff.py <baseline.csv> <new.csv> [mode-filter]
"""
import csv
import sys
from collections import Counter


def load(p, mode=None):
    with open(p) as f:
        rows = {}
        for r in csv.DictReader(f):
            if mode and r['mode'] != mode:
                continue
            rows[(r['name'], r['mode'])] = r
        return rows


base_p, new_p = sys.argv[1], sys.argv[2]
mode = sys.argv[3] if len(sys.argv) > 3 else None
b = load(base_p, mode)
n = load(new_p, mode)
print('baseline rows %d   new rows %d' % (len(b), len(n)))
for nm, d in (('baseline', b), ('new     ', n)):
    print('%s status %s' % (nm, dict(sorted(Counter(r['status']
                                                    for r in d.values()).items()))))
    print('%s dump   %s' % (nm, dict(sorted(Counter(r['dump']
                                                    for r in d.values()).items()))))
diffs = []
for k in sorted(set(b) | set(n)):
    rb, rn = b.get(k), n.get(k)
    if rb is None or rn is None:
        diffs.append('%s %s: PRESENT-ONLY-IN %s' %
                     (k[0], k[1], 'new' if rb is None else 'baseline'))
        continue
    if rb['status'] != rn['status'] or rb['dump'] != rn['dump']:
        diffs.append('%s %s: status %s -> %s   dump %s -> %s' %
                     (k[0], k[1], rb['status'], rn['status'], rb['dump'],
                      rn['dump']))
print('ROW DIFFS %d' % len(diffs))
for d in diffs:
    print('  ' + d)
