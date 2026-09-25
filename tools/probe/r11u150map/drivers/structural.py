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
CLASSES = [   # r11u150: map 5's classes by persistent id + r11u148share's decode letters (E, E2, I = its law.patch; D2, D, G, ARR, C3 = pair-A decodes)
    ('E SHARED func_call (r11u148 E: evalFunc keeps the call; law.patch)', lambda c: c in ('N0133', 'N0284')),
    ('E2 SHARED constant (r11u148 E2: gen-scope UINT own copy; law.patch)', lambda c: c == 'N0554'),
    ('I EXTRA CONSTANT under ref_obj (r11u148 I: package signature range binds the top-view constant; law.patch)', lambda c: c == 'N0764'),
    ('D2 CAST TARGET (r11u148 D2: the two package listings\' cast targets swapped)', lambda c: c in ('N0024', 'N0059', 'N2383', 'N2384')),
    ('D MEMBER-DEFAULT COPY (r11u148 D: operation-valued member default, module-default evalFunc stamp)', lambda c: c == 'N0045'),
    ('G EXTRA FOLDED CONSTANT (r11u148 G: the kept concatenation, taken-arm parameter Rhs share)', lambda c: c == 'N0724'),
    ('ARR NET BINDING of a procedural reference (r11u148 ARR: binds the first var_select naming the array)', lambda c: c == 'N0046'),
    ('C2 CONSTANT COPIED / SHARED (array_expr default pattern)', lambda c: c in ('N0441', 'N2385')),
    ('C3 IMPORT-CLONE ARRAY TYPESPEC', lambda c: c in ('N0142', 'N0451')),
]
ff = lambda s: s.split(':', 1)[1].split('(')[0] if s.startswith('differ:') else s
struct = [r for r in FL if ff(r['strict']) in ('depth', 'type', 'count')]
by = collections.defaultdict(list)
for r in struct:
    c = r['first_cluster']; cls = next((n for n, f in CLASSES if c in CI and f(c)), 'H OTHER (first cluster outside the classes)')
    by[cls].append(r)
print(f'# the structural row-modes (first field depth/type/count) at 98aa49db: {len(struct)} row-modes, '
      f'{len({(r["corpus"], r["test"]) for r in struct})} tests')
print('# class, row-mode, strict cell, first cluster, its coverage, open clusters left after the pairs, clears with the pairs\n')
for cls in [n for n, _ in CLASSES] + ['H OTHER (first cluster outside the classes)']:
    rs = by.get(cls, [])
    if not rs: print(f'## {cls}: 0 row-modes\n'); continue
    print(f"## {cls}: {len(rs)} row-modes, {len({(r['corpus'], r['test']) for r in rs})} tests, clear with pairs A+B: {sum(1 for r in rs if 'A+B' in r['clears_with_pairs'])}; measured with the share law: {sum(1 for r in rs if 'measured' in r.get('clears_after_both_pairs', ''))}")
    for r in sorted(rs, key=lambda r: (r['corpus'], r['mode'], r['test'])):
        extra = '' if not cls.startswith('H') else '  key=' + CI[r['first_cluster']]['key']
        print(f"  {r['corpus']}/{r['mode']}/{r['test']}  {r['strict']}  {r['first_cluster']}  {r['first_cluster_coverage']}  open_clusters={r['open_clusters']}  after share (measured): {r.get('strict_after_share', '-')}  after both pairs: {r.get('clears_after_both_pairs', '-')}  open after pairs: {r.get('open_clusters_after_pairs', '-')}{extra}")
    print()
print('## the share law (r11u148share law.patch, landed by pair B r11u146): MEASURED cross-section in evidence/report.txt section 1')
