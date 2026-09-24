#!/usr/bin/env python3
"""r11u142: the README's markdown tables from the map's csvs (cluster_index.csv with the after-nb and
after-p137 columns, fail_list.csv). Args: <map dir> -> stdout (sections separated by '#### ')."""
import csv, sys, re, collections
M = sys.argv[1]
CI = {r['cluster_id']: r for r in csv.DictReader(open(f'{M}/cluster_index.csv'))}
FL = list(csv.DictReader(open(f'{M}/fail_list.csv')))
iscov = lambda c: CI[c]['coverage'].startswith('COVERED')
def site(c, n=150):
    s = CI[c]['site']; note = ''
    m = re.search(r' \[(DECODED[^\]]*|NOTE[^\]]*|SHARED[^\]]*|pass-133[^\]]*|emitMixedHierPath[^\]]*|r11v133[^\]]*)\]', s)
    if m: note = ' — ' + m.group(1)[:140]
    s = re.sub(r' \[[^\]]*\]', '', s)
    return (s[:n] + note).replace('|', '/')
key = lambda c: '`' + CI[c]['key'].replace('|', '\\|') + '`'
cov = lambda c, n=60: CI[c]['coverage'].replace('|', '/')[:n]
ex = lambda c, n=100: CI[c]['example'][:n].replace('|', '/')
P = print
P('#### open')
P('| rank | cluster | rows sl/u2r | tests | first in | probe | after nb | after p137 | alone (p137) | ground | coverage | key | example | site (mint < caller < caller) |')
P('|---|---|---|---|---|---|---|---|---|---|---|---|---|---|')
opn = sorted([c for c in CI if not iscov(c) and int(CI[c]['rows']) > 0], key=lambda c: int(CI[c]['rank']))
for c in opn[:50]:
    r = CI[c]
    P(f"| {r['rank']} | {c} | {r['rows']} {r['rows_surelog']}/{r['rows_uhdm2rtlil']} | {r['tests']} | {r['first_in_rows']} | {r['probe_cases']} | {r['rows_after_nb']} | {r['rows_after_p137']} | {r['alone_on_top_of_pairs_after_p137']} | {r['ground']} | {cov(c, 48)} | {key(c)} | {ex(c, 90)} | {site(c)} |")
P('#### covered')
P('| cluster | rows sl/u2r | tests | first in | probe | after nb | after p137 (probe) | coverage | key | site |')
P('|---|---|---|---|---|---|---|---|---|---|')
for c in sorted([c for c in CI if iscov(c)], key=lambda c: int(CI[c]['rank'])):
    r = CI[c]
    P(f"| {c} | {r['rows']} {r['rows_surelog']}/{r['rows_uhdm2rtlil']} | {r['tests']} | {r['first_in_rows']} | {r['probe_cases']} | {r['rows_after_nb']} | {r['rows_after_p137']} ({r['probe_after_p137']}) | {cov(c, 90)} | {key(c)} | {site(c, 110)} |")
P('#### first')
fc = collections.Counter(r['first_cluster'] for r in FL)
P('| first cluster | row-modes it heads | after nb | after p137 | coverage | key | site |'); P('|---|---|---|---|---|---|---|')
for c, n in fc.most_common(30):
    r = CI[c]
    P(f"| {c} | {n} | {r['first_in_after_nb']} | {r['first_in_after_p137']} | {cov(c, 60)} | {key(c)} | {site(c, 120)} |")
P(f'distinct first clusters: {len(fc)}')
