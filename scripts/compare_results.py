#!/usr/bin/env python3
"""Compare a fresh results CSV against a committed baseline CSV.

    compare_results.py <fresh.csv> <committed.csv> [--modes default,testflags]

Two shapes are read: the corpus scoreboards of verify_golden.py
(`name,mode,status,detail,blocked_by,strict`, joined on (name, mode)) and the
probe-case csv of check_probe.py (`case,status,detail,strict`, joined on the
case; --modes does not apply).

Since the strict flip (2026-09-24) the status order is
    CMP_EQUAL (probe: EQUAL) > STRICT_NOTEQUAL > every other status:
a row is equal only when uhdm-cmp AND uhdm-strictcmp read it equal, and a
STRICT_NOTEQUAL row is judge-equal with a strict difference the baseline
records. A REGRESSION is a row that leaves CMP_EQUAL, or goes from
STRICT_NOTEQUAL to a status the judge does not read equal. A CONVERSION is a
row that enters CMP_EQUAL. A CHANGE is any other status change, or a
STRICT_NOTEQUAL row whose strict verdict changed (printed old -> new with the
count delta when the first field is the same). A row only in the fresh csv
must be CMP_EQUAL / EQUAL, else it is a regression. A baseline row the fresh
csv lacks is a regression too (a test or case that was not run, or that the
harness lost to an exception), unless --filter (the REGEX the run was given,
matched as the harness matches it: re.search on the test name or the case
path) excludes it. A row of mode `harness` (verify_golden.py's record of an
exception) and a key listed twice in either csv are regressions. Exit status
is 1 on any regression, else 0.
"""
import argparse
import csv
import re
import sys
from collections import Counter

EQUAL = ('CMP_EQUAL', 'EQUAL')
STRICT_NE = 'STRICT_NOTEQUAL'


def load(path, modes, bad):
    """-> {key: (status, strict)}; key is (name, mode), or (case, 'probe').
    Appends to `bad` every key listed twice and every `harness` row."""
    rows = {}
    with open(path, newline='') as f:
        rd = csv.reader(f)
        header = next(rd, None) or []
        probe = bool(header) and header[0].lstrip('\ufeff') == 'case'
        for r in rd:
            if not r:
                continue
            if probe:
                k, v = (r[0], 'probe'), (r[1], r[3] if len(r) > 3 else '')
            elif r[1] == 'harness':
                bad.append(f'HARNESS {r[0]} {r[2]} {r[3]} ({path})')
                continue
            elif r[1] in modes:
                k, v = (r[0], r[1]), (r[2], r[5] if len(r) > 5 else '')
            else:
                continue
            if k in rows:
                bad.append(f'DUPLICATE {" ".join(k)} ({path})')
            rows[k] = v
    return rows, probe


def delta(old, new):
    """' [line +3]' when both verdicts name the same first field."""
    mo = re.fullmatch(r'differ:(\w+)\((\d+)\)', old)
    mn = re.fullmatch(r'differ:(\w+)\((\d+)\)', new)
    if mo and mn and mo.group(1) == mn.group(1):
        return f' [{mn.group(1)} {int(mn.group(2)) - int(mo.group(2)):+d}]'
    return ''


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('fresh')
    ap.add_argument('committed')
    ap.add_argument('--modes', default='default,testflags')
    ap.add_argument('--filter', default=None,
                    help='the REGEX the fresh run was given: baseline rows it excludes are not expected')
    a = ap.parse_args()
    modes = set(a.modes.split(','))
    malformed = []
    (fresh, probe), (base, _) = load(a.fresh, modes, malformed), load(a.committed, modes, malformed)
    if a.filter:
        base = {k: v for k, v in base.items() if re.search(a.filter, k[0])}
    regress, convert, change = [], [], []
    for k, (st, sv) in sorted(fresh.items()):
        if k not in base:
            continue
        bst, bsv = base[k]
        if bst == st:
            if st == STRICT_NE and bsv != sv:
                change.append((k, f'{bst} {bsv}', f'{sv}{delta(bsv, sv)}'))
            continue
        if bst in EQUAL or (bst == STRICT_NE and st not in EQUAL):
            regress.append((k, bst, f'{st} {sv}' if st == STRICT_NE else st))
        elif st in EQUAL:
            convert.append((k, f'{bst} {bsv}' if bst == STRICT_NE else bst, st))
        else:
            change.append((k, bst, f'{st} {sv}' if st == STRICT_NE else st))
    only_fresh = sorted(set(fresh) - set(base))
    only_base = sorted(set(base) - set(fresh))
    fresh_bad = [k for k in only_fresh if fresh[k][0] not in EQUAL]
    hist = Counter((m, st) for (_n, m), (st, _sv) in fresh.items())
    for mode in (['probe'] if probe else sorted(modes)):
        cells = ' '.join(f'{s}={c}' for (m, s), c in sorted(hist.items()) if m == mode)
        print(f'[{mode}] {cells}')

    def label(k):
        return k[0] if k[1] == 'probe' else f'{k[0]} {k[1]}'
    for lab, lst in (('REGRESSION', regress), ('CONVERSION', convert), ('CHANGE', change)):
        for k, b, r in lst:
            print(f'{lab} {label(k)} {b} -> {r}')
    for k in only_fresh:
        st, sv = fresh[k]
        tag = 'ONLY-FRESH' if st in EQUAL else 'REGRESSION ONLY-FRESH (not equal)'
        print(f'{tag} {label(k)} {st} {sv}'.rstrip())
    for k in only_base[:20]:   # not run, or lost to a harness exception
        print(f'REGRESSION ONLY-COMMITTED (not run) {label(k)} {base[k][0]}')
    if len(only_base) > 20:
        print(f'REGRESSION ONLY-COMMITTED ... and {len(only_base) - 20} more')
    for m in malformed:
        print(f'REGRESSION {m}')
    nreg = len(regress) + len(fresh_bad) + len(only_base) + len(malformed)
    print(f'regressions={nreg} conversions={len(convert)} changes={len(change)} '
          f'only-fresh={len(only_fresh)} only-committed={len(only_base)}')
    sys.exit(1 if nreg else 0)


if __name__ == '__main__':
    main()
