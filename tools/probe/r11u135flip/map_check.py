#!/usr/bin/env python3
"""The new baselines' STRICT_NOTEQUAL rows against the explicit residue of
tools/probe/r11u132map (the third-edition fail lists, measured at 4f73d52f with
the same comparator and exporter bytes as b3886a1c).

    map_check.py <golden_surelog.csv> <golden_uhdm2rtlil.csv> <golden_probe.csv>

Corpus: every STRICT_NOTEQUAL row-mode is a fail_list.csv row with the same
strict verdict and vice versa (the map writes a fenced test as FENCED_<n>; those
rows are matched by mode and verdict against the rows the map does not name, and
never printed by name). Probe: the STRICT_NOTEQUAL cases are exactly
probe_fail_list.csv's cases, with the same first field. Exit 1 on a mismatch.
"""
import collections
import csv
import os
import sys

MAP = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'r11u132map')


def read(p):
    with open(p, newline='') as f:
        return list(csv.DictReader(f))


def main():
    sl, u2r, pr = sys.argv[1:4]
    bad = []
    fail = read(os.path.join(MAP, 'fail_list.csv'))
    mapped = {(r['corpus'], r['test'], r['mode']): r['strict'] for r in fail}
    fenced = collections.Counter((r['corpus'], r['mode'], r['strict'])
                                 for r in fail if r['test'].startswith('FENCED_'))
    ours = {}
    for corpus, p in (('surelog', sl), ('uhdm2rtlil', u2r)):
        for r in read(p):
            if r['status'] == 'STRICT_NOTEQUAL':
                ours[(corpus, r['name'], r['mode'])] = r['strict']
    unnamed = collections.Counter()
    for k, v in ours.items():
        if k in mapped:
            if mapped[k] != v:
                bad.append(f'verdict {k}: map {mapped[k]} ours {v}')
        else:
            unnamed[(k[0], k[2], v)] += 1
    if unnamed != fenced:
        bad.append(f'rows the map does not name: {sum(unnamed.values())} '
                   f'vs the map\'s fenced rows {sum(fenced.values())} (by mode and verdict)')
    for k in mapped:
        if not k[1].startswith('FENCED_') and k not in ours:
            bad.append(f'map row not STRICT_NOTEQUAL in the baseline: {k}')
    per = collections.Counter((k[0], k[2]) for k in ours)
    print('corpus STRICT_NOTEQUAL row-modes:', dict(sorted(per.items())),
          f'total={len(ours)} tests={len({(k[0], k[1]) for k in ours})}; '
          f'map rows={len(mapped)} (fenced rows matched by mode and verdict: {sum(fenced.values())})')
    pf = {r['case']: r['strict'] for r in read(os.path.join(MAP, 'probe_fail_list.csv'))}
    # The map spells a case dir named `arms` as `cases` (tests/probe has 8
    # such dirs; 91 of their cases are STRICT_NOTEQUAL); read ours the same way.
    po = {'/'.join('cases' if seg == 'arms' else seg for seg in r['case'].split('/')):
          r['strict'].split(':', 1)[1].split('(')[0]
          for r in read(pr) if r['status'] == 'STRICT_NOTEQUAL'}
    if set(pf) != set(po):
        bad.append(f'probe case sets: only-map={len(set(pf)-set(po))} only-ours={len(set(po)-set(pf))}')
    for c in set(pf) & set(po):
        if pf[c] != po[c]:
            bad.append(f'probe field {c}: map {pf[c]} ours {po[c]}')
    print(f'probe STRICT_NOTEQUAL cases: {len(po)}; map cases: {len(pf)}')
    for b in bad[:40]:
        print('MISMATCH', b)
    print('MAP CHECK', 'FAIL' if bad else 'PASS', f'mismatches={len(bad)}')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
