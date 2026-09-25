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
CLASSES = [   # r11u156: r11u151's decode letters (D2, ARR, G, D, C3), by persistent map ids
    ('D2 CAST TARGET (r11u151 D2: the two package listings\' cast targets swapped; law pkgTdCastTargetOwnView151)', lambda c: c in ('N2383', 'N2384')),
    ('ARR PROCEDURAL WHOLE-REFERENCE BINDING (r11u151 ARR: blockLhsVarSelBindsWholeRef151 + nonblockingSelLhsBindsWholeRef151)', lambda c: c == 'N0046'),
    ('G THE KEPT CONCATENATION (r11u151 G: condTakenParamRhsShared151 + concatArrParamDefTs151)', lambda c: c in ('N0724', 'N1129')),
    ('D MEMBER-DEFAULT LEFTOVERS (r11u151 D: patLeftoverOrphanCopy151 + hierSizeCastBaseStructTs151)', lambda c: c in ('N0045', 'N0758', 'N0756', 'N0759')),
    ('C3 PORT CONNECTION OPERATION (r11u151 C3: nestedPatOpTsNoParent151 + the pair-B scratch)', lambda c: c in ('N0417', 'N0534')),
    ('E SHARED func_call (r11u148 E, landed by pass 146: its frontier)', lambda c: c in ('N0133', 'N0284')),
    ('C2 THE DEFAULT FILL (pass 145 defaultFillImportCopies145)', lambda c: c in ('N0441', 'N2385')),
    ('P0286 comb_dyn_2d_packed_sel SEL_W reference (pair A N0286)', lambda c: c == 'N0286'),
]
ff = lambda s: s.split(':', 1)[1].split('(')[0] if s.startswith('differ:') else s
struct = [r for r in FL if ff(r['strict']) in ('depth', 'type', 'count')]
by = collections.defaultdict(list)
for r in struct:
    c = r['first_cluster']; cls = next((n for n, f in CLASSES if c in CI and f(c)), 'H OTHER (first cluster outside the classes)')
    by[cls].append(r)
print(f'# the structural row-modes (first field depth/type/count) at 89d599ef: {len(struct)} row-modes, '
      f'{len({(r["corpus"], r["test"]) for r in struct})} tests')
print('# class, row-mode, strict cell, first cluster, its coverage, open clusters left after the pairs, clears with the pairs\n')
for cls in [n for n, _ in CLASSES] + ['H OTHER (first cluster outside the classes)']:
    rs = by.get(cls, [])
    if not rs: print(f'## {cls}: 0 row-modes\n'); continue
    print(f"## {cls}: {len(rs)} row-modes, {len({(r['corpus'], r['test']) for r in rs})} tests, clear with pairs A+B: {sum(1 for r in rs if 'A+B' in r['clears_with_pairs'])}; measured with the law binary: {sum(1 for r in rs if 'measured' in r.get('clears_after_both_pairs', ''))}")
    for r in sorted(rs, key=lambda r: (r['corpus'], r['mode'], r['test'])):
        extra = '' if not cls.startswith('H') else '  key=' + CI.get(r['first_cluster'], {}).get('key', 'FENCED (not dispatched)')
        print(f"  {r['corpus']}/{r['mode']}/{r['test']}  {r['strict']}  {r['first_cluster']}  {r['first_cluster_coverage']}  open_clusters={r['open_clusters']}  after the law (measured): {r.get('strict_after_law', '-')}  after both pairs: {r.get('clears_after_both_pairs', '-')}  open after pairs: {r.get('open_clusters_after_pairs', '-')}{extra}")
    print()
print('## the law binary (r11u151 law_after_r11u145.patch + pairB_c3_scratch.patch): MEASURED cross-section in evidence/report.txt section 1')
