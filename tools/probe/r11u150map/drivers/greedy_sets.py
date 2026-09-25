#!/usr/bin/env python3
"""r11u150: the per-ground briefs by SETS. The single-cluster greedy (report6.py section 6) stalls where a row needs
two or three clusters at once (D2's N2383+N2384 is the plain case), so here a candidate is the whole open-cluster
set of a row left after both pairs (share measured + the rest optimistic) whose open clusters all belong to one
ground (<= 4 clusters); greedy by marginal row-modes cleared per cluster added, ties by rows carried.
Args: <map out dir (fail_list.csv, cluster_index.csv after report6.py)> [fenced-redaction repo]"""
import csv, sys, collections, re, os
OUT = sys.argv[1]
FEN = set()
if len(sys.argv) > 2:
    t = open(os.path.join(sys.argv[2], 'RESUME.md')).read()
    FEN = set(re.findall(r'`([A-Za-z_][A-Za-z0-9_]*)`', re.search(r'The four slang-fenced tests(.*?)are NEVER dispatched', t, re.S).group(1)))
red = lambda n: 'FENCED_1' if n in FEN else n
F = {(r['corpus'], r['mode'], r['test']): r for r in csv.DictReader(open(f'{OUT}/fail_list.csv'))}
CI = {r['cluster_id']: r for r in csv.DictReader(open(f'{OUT}/cluster_index.csv'))}
after = {k: set(r['open_clusters_after_pairs'].split()) for k, r in F.items() if r['clears_after_both_pairs'] == 'no'}
base = len(F) - len(after)
tests_all = collections.defaultdict(list)
for k in F: tests_all[(k[0], k[2])].append(k)
def cleared(S):
    ks = {k for k, s in after.items() if s <= S}
    tt = {t for t, ms in tests_all.items() if all((m not in after) or (m in ks) for m in ms)}
    return ks, tt
esc = lambda s: s.replace('|', '\\|')
for g in ('A', 'B'):
    cands = {frozenset(s) for s in after.values() if 0 < len(s) <= 4 and all(CI[c]['ground'] == g for c in s)}
    cum = set(); print(f'## ground {g}: {len(cands)} candidate sets (rows left after both pairs whose open clusters are all ground {g})')
    print('| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |')
    print('|---|---|---|---|---|---|---|---|')
    for i in range(25):
        n0 = len(cleared(cum)[0]); best = None
        for s in cands:
            add = s - cum
            if not add: continue
            gain = len(cleared(cum | s)[0]) - n0
            sc = (gain / len(add), gain, sum(int(CI[c]['rows_after_pairs']) for c in add))
            if best is None or sc > best[0]: best = (sc, s, add, gain)
        if best is None or best[3] <= 0: break
        cum |= best[1]; ks, tt = cleared(cum)
        newrows = sorted(k for k in ks if not after[k] <= cum - best[2])
        add = sorted(best[2])
        print(f"| {i+1} | {' + '.join(add)} | {best[3]} | {base + len(ks)} | {len(tt)} | "
              f"{' '.join(red(k[2]) + '/' + k[1][0] + ('/u2r' if k[0] == 'uhdm2rtlil' else '') for k in newrows)} | "
              f"{'; '.join('`' + esc(CI[c]['key']) + '`' for c in add)} | {esc(CI[add[0]]['site'])[:170]} |")
    ks, tt = cleared(cum)
    print(f'\nground {g}: the {len(cum)} clusters above clear {len(ks)} row-modes on top of the pairs ({base + len(ks)} with them)\n')
