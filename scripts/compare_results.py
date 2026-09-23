#!/usr/bin/env python3
"""Compare a fresh verify_golden.py CSV against a committed results CSV.

    compare_results.py <fresh.csv> <committed.csv> [--modes default,testflags]

Rows are joined on (name, mode). A row whose STATUS differs is a regression
when it moved away from CMP_EQUAL and a conversion when it moved to it; every
other status change is reported as a change. Rows absent on either side are
listed. Exit status is 1 on any regression, else 0.
"""
import argparse
import csv
import sys
from collections import Counter


def load(path, modes):
    rows = {}
    with open(path, newline='') as f:
        for r in csv.reader(f):
            if not r or r[0] == 'name' or r[1] not in modes:
                continue
            rows[(r[0], r[1])] = r
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('fresh')
    ap.add_argument('committed')
    ap.add_argument('--modes', default='default,testflags')
    a = ap.parse_args()
    modes = set(a.modes.split(','))
    fresh, base = load(a.fresh, modes), load(a.committed, modes)
    regress, convert, change = [], [], []
    for k, r in sorted(fresh.items()):
        b = base.get(k)
        if b is None or b[2] == r[2]:
            continue
        if b[2] == 'CMP_EQUAL':
            regress.append((k, b[2], r[2]))
        elif r[2] == 'CMP_EQUAL':
            convert.append((k, b[2], r[2]))
        else:
            change.append((k, b[2], r[2]))
    only_fresh = sorted(set(fresh) - set(base))
    only_base = sorted(set(base) - set(fresh))
    hist = Counter((m, r[2]) for (_n, m), r in fresh.items())
    for mode in sorted(modes):
        cells = ' '.join(f'{s}={c}' for (m, s), c in sorted(hist.items()) if m == mode)
        print(f'[{mode}] {cells}')
    for label, lst in (('REGRESSION', regress), ('CONVERSION', convert), ('CHANGE', change)):
        for (n, m), b, r in lst:
            print(f'{label} {n} {m} {b} -> {r}')
    for n, m in only_fresh:
        print(f'ONLY-FRESH {n} {m} {fresh[(n, m)][2]}')
    for n, m in only_base:
        print(f'ONLY-COMMITTED {n} {m} {base[(n, m)][2]}')
    print(f'regressions={len(regress)} conversions={len(convert)} changes={len(change)} '
          f'only-fresh={len(only_fresh)} only-committed={len(only_base)}')
    sys.exit(1 if regress else 0)


if __name__ == '__main__':
    main()
