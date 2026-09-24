#!/usr/bin/env python3
"""Flip preview: per corpus and mode, raw vs canonical strict verdicts of the
judge-equal row-modes (the re-measure), first-field histogram, and the tests
strict-equal in one mode but not the other.  usage: flip_preview.py <runall.csv>"""
import collections, csv, sys
rows = list(csv.DictReader(open(sys.argv[1])))
by = collections.defaultdict(list)
for r in rows:
    by[(r['corpus'], r['mode'])].append(r)
print('| corpus | mode | judge-equal | raw strict-equal | canon strict-equal | canon differ by first field |')
print('|---|---|---|---|---|---|')
for k in sorted(by):
    rs = by[k]
    h = collections.Counter(r['can_v'].split('(')[0].replace('differ:', '') for r in rs if r['can_v'] != 'equal')
    print(f"| {k[0]} | {k[1]} | {len(rs)} | {sum(r['raw_v'] == 'equal' for r in rs)} | "
          f"{sum(r['can_v'] == 'equal' for r in rs)} | " + ', '.join(f'{f} {n}' for f, n in h.most_common()) + ' |')
tot = collections.Counter()
for r in rows:
    tot[(r['corpus'], r['can_v'].split('(')[0].replace('differ:', ''))] += 1
t = collections.defaultdict(dict)
for r in rows:
    t[(r['corpus'], r['test'])][r['mode']] = r['can_v'] == 'equal'
print()
for c in ('surelog', 'uhdm2rtlil'):
    both = [k for k, v in t.items() if k[0] == c and len(v) == 2 and all(v.values())]
    one = sorted((k[1], [m for m, e in v.items() if e][0]) for k, v in t.items()
                 if k[0] == c and len(v) == 2 and sum(v.values()) == 1)
    single = [k for k, v in t.items() if k[0] == c and len(v) == 1]
    print(f'{c}: tests strict-equal in both modes {len(both)}; in one mode only {len(one)}; judged in one mode only {len(single)}')
    for n, m in one:
        print(f'  {n}: equal in {m} only')
