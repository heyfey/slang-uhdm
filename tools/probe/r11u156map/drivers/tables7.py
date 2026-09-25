#!/usr/bin/env python3
"""r11u156: the README's markdown tables from the two cross-sections (out = 89d599ef + the law binary measured;
out147 = pass 147 measured). Args: <W> -> stdout (markdown)."""
import csv, sys, collections, re, os
W = sys.argv[1]
def load(o):
    CI = {r['cluster_id']: r for r in csv.DictReader(open(f'{W}/{o}/cluster_index.csv'))}
    FL = list(csv.DictReader(open(f'{W}/{o}/fail_list.csv')))
    return CI, FL
CI, FL = load('out'); CJ, FJ = load('out147')
esc = lambda s: s.replace('|', '\\|')
def site(s, n=150):
    s = re.sub(r' \[r11u1\d\dmap pin[^\]]*\]', '', s); return esc(s[:n]) + ('...' if len(s) > n else '')
P = print
# T1 ranked OPEN clusters on top of pass 147 (measured) + pair B (optimistic)
opn = [c for c, r in CJ.items() if int(r['rows_after_pairs']) > 0]
opn.sort(key=lambda c: (-int(CJ[c]['rows_after_pairs']), -int(CJ[c]['alone_on_top_of_pairs']), -int(CJ[c]['probe_after_law']), c))
P('### T1. Ranked OPEN clusters on top of pass 147 (measured) + pair B r11u152 (optimistic): top 60 of', len(opn))
P()
P('| # | cluster | rows left (89d599ef) | sl/u2r at 89d599ef | tests | heads | alone | probe (after 147) | ground | status | key | site (mint < caller < caller) |')
P('|---|---|---|---|---|---|---|---|---|---|---|---|')
for i, c in enumerate(opn[:60]):
    r = CJ[c]
    st = r['coverage']; st = st.replace('OPEN (residue of pass 147: COVERED r11u147', 'OPEN (pass-147 residue')[:70]
    P(f"| {i+1} | {c} | {r['rows_after_pairs']} ({r['rows']}) | {r['rows_surelog']}/{r['rows_uhdm2rtlil']} | {r['tests']} | {r['first_in_after_pairs']} | {r['alone_on_top_of_pairs']} | {r['probe_after_law']} | {r['ground']} | {esc(st)} | `{esc(r['key'])}` | {site(r['site'])} |")
P()
# T2 coverage by the live pair B, and pair A's named list after pass 147
P('### T2. Pair B r11u152: its covered clusters (named, routed, C3 measured), rows at 89d599ef -> after pass 147')
P()
P('| cluster | rows 89d599ef (sl/u2r) | after pass 147 | probe 89d599ef -> after 147 | coverage | key |')
P('|---|---|---|---|---|---|')
B = sorted((c for c, r in CI.items() if r['coverage'].startswith('COVERED') and 'r11u152' in r['coverage'].split('(')[0]), key=lambda c: (-int(CI[c]['rows']), c))
for c in B:
    r, j = CI[c], CJ[c]
    P(f"| {c} | {r['rows']} ({r['rows_surelog']}/{r['rows_uhdm2rtlil']}) | {j['rows_after_law']} | {r['probe_cases']} -> {j['probe_after_law']} | {esc(r['coverage'][:80])} | `{esc(r['key'])}` |")
P()
P('### T3. Pair A r11u147 (landed as pass 147): its covered clusters, rows at 89d599ef -> after pass 147 (measured)')
P()
P('| cluster | rows 89d599ef | after pass 147 | probe 89d599ef -> after 147 | coverage at 89d599ef | key |')
P('|---|---|---|---|---|---|')
A = sorted((c for c, r in CI.items() if r['coverage'].startswith('COVERED') and 'r11u147' in r['coverage'].split('(')[0]), key=lambda c: (-int(CI[c]['rows']), c))
for c in A:
    r, j = CI[c], CJ[c]
    P(f"| {c} | {r['rows']} | {j['rows_after_law']} | {r['probe_cases']} -> {j['probe_after_law']} | {esc(r['coverage'][:80])} | `{esc(r['key'])}` |")
P()
# T4 the fail list after pass 147 + pair B, by first cluster
P('### T4. First clusters of the rows left after pass 147 + pair B (row-modes each heads)')
P()
fc = collections.Counter(r['first_cluster_after_law'] for r in FJ if r['clears_after_both_pairs'] == 'no')
P('| first cluster | row-modes it heads | ground | status | key | site |')
P('|---|---|---|---|---|---|')
for c, n in fc.most_common(30):
    r = CJ.get(c)
    if not r: P(f'| {c} | {n} | | | | |'); continue
    P(f"| {c} | {n} | {r['ground']} | {esc(r['coverage'][:50])} | `{esc(r['key'])}` | {site(r['site'], 120)} |")
P()
# T5 fail-list size per corpus/mode
P('### T5. Fail-list size')
P()
def cnt(F, pred):
    c = collections.Counter((r['corpus'], r['mode']) for r in F if pred(r)); return c
tot = cnt(FL, lambda r: True)
law = cnt(FL, lambda r: not r['clears_after_both_pairs'].startswith('yes (law') and not (r['first_cluster'] == 'FENCED'))
aft = cnt(FL, lambda r: r['clears_after_both_pairs'] == 'no')
p147 = cnt(FJ, lambda r: not r['clears_after_both_pairs'].startswith('yes (law') and r['first_cluster'] != 'FENCED')
a147 = cnt(FJ, lambda r: r['clears_after_both_pairs'] == 'no')
P('| corpus | mode | 89d599ef (incl. fenced) | after the r11u151 law binary (measured, excl. fenced) | after both pairs as briefed (law measured + named optimistic) | after pass 147 (measured) | after pass 147 + pair B (optimistic) |')
P('|---|---|---|---|---|---|---|')
for k in sorted(tot):
    P(f'| {k[0]} | {k[1]} | {tot[k]} | {law[k]} | {aft[k]} | {p147[k]} | {a147[k]} |')
P(f"| **all** | | **{sum(tot.values())}** | {sum(law.values())} | {sum(aft.values())} | {sum(p147.values())} | **{sum(a147.values())}** |")
