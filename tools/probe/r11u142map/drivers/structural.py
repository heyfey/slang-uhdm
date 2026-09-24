#!/usr/bin/env python3
"""r11u138: the structural row-modes (strict first field depth / type / count),
classed by their first cluster with r11u132map section 5's classes (by the
persistent N ids), plus the net-binding class listed in full (every row-mode
carrying a net-binding cluster, whatever its first field).
Args: <out dir> (fail_list.csv, cluster_index.csv, clusters.csv) -> stdout."""
import csv, sys, collections
OUT = sys.argv[1]
FL = list(csv.DictReader(open(f'{OUT}/fail_list.csv')))
CI = {r['cluster_id']: r for r in csv.DictReader(open(f'{OUT}/cluster_index.csv'))}
CL = collections.defaultdict(set)
for r in csv.DictReader(open(f'{OUT}/clusters.csv')):
    CL[(r['corpus'], r['mode'], r['test'])].add(r['cluster_id'])
CLASSES = [
    ('A NET-BINDING', lambda c: 'net binding' in CI[c]['coverage'] or 'net-binding' in CI[c]['coverage']),
    ('B TYPEDEF-ALIAS on the net typespec', lambda c: c == 'N0085'),
    ('C IMPORTED-PARAMETER CLONE', lambda c: c == 'N0002'),
    ('C3 IMPORT-CLONE ARRAY TYPESPEC (pass-133 R6)', lambda c: c in ('N0142', 'N0451')),
    ('C2 CONSTANT COPIED', lambda c: c == 'N0441'),
    ('D MEMBER-DEFAULT COPY', lambda c: c == 'N0045'),
    ('D2 CAST TARGET', lambda c: c in ('N0024', 'N0059')),
    ('E SHARED func_call', lambda c: c == 'N0133'),
    ('E2 SHARED constant', lambda c: c == 'N0554'),
    ('F TYPE-PARAMETER DEF NET', lambda c: c == 'N0770'),
    ('G EXTRA FOLDED CONSTANT', lambda c: c == 'N0724'),
    ('I EXTRA CONSTANT under ref_obj', lambda c: c == 'N0764'),
]
ff = lambda s: s.split(':', 1)[1].split('(')[0] if s.startswith('differ:') else s
struct = [r for r in FL if ff(r['strict']) in ('depth', 'type', 'count')]
by = collections.defaultdict(list)
for r in struct:
    c = r['first_cluster']; cls = next((n for n, f in CLASSES if c in CI and f(c)), 'H OTHER (first cluster outside the classes)')
    by[cls].append(r)
print(f'# the structural row-modes (first field depth/type/count) at a7bee711: {len(struct)} row-modes, '
      f'{len({(r["corpus"], r["test"]) for r in struct})} tests')
print('# class, row-mode, strict cell, first cluster, its coverage, open clusters left after the pairs, clears with the pairs\n')
for cls in [n for n, _ in CLASSES] + ['H OTHER (first cluster outside the classes)']:
    rs = by.get(cls, [])
    if not rs: print(f'## {cls}: 0 row-modes\n'); continue
    print(f"## {cls}: {len(rs)} row-modes, {len({(r['corpus'], r['test']) for r in rs})} tests, clear with pairs A+B: {sum(1 for r in rs if 'A+B' in r['clears_with_pairs'])}")
    for r in sorted(rs, key=lambda r: (r['corpus'], r['mode'], r['test'])):
        extra = '' if not cls.startswith('H') else '  key=' + CI[r['first_cluster']]['key']
        print(f"  {r['corpus']}/{r['mode']}/{r['test']}  {r['strict']}  {r['first_cluster']}  {r['first_cluster_coverage']}  open_clusters={r['open_clusters']}  {r['clears_with_pairs']}{extra}")
    print()
nb = [c for c in CI if 'net binding' in CI[c]['coverage'] or 'net-binding' in CI[c]['coverage']]
rows = sorted(k for k, s in CL.items() if s & set(nb))
print(f'## NET-BINDING class in full: clusters {" ".join(sorted(nb))}; {len(rows)} row-modes carry one, '
      f'{len({(k[0], k[2]) for k in rows})} tests')
fl = {(r['corpus'], r['mode'], r['test']): r for r in FL}
for k in rows:
    r = fl[k]; mine = sorted(CL[k] & set(nb))
    only = all(CI[c]['coverage'].startswith('COVERED') for c in CL[k])
    print(f"  {'/'.join(k)}  {r['strict']}  first={r['first_cluster']}  netbind={','.join(mine)}  clusters={r['clusters']}  "
          f"{'CLEARS with the pairs (net binding in pair B)' if only else ''}  downstream={r['downstream']}")
