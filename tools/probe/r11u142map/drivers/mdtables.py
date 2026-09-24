#!/usr/bin/env python3
"""r11u138 (r11u142: + the after-nb columns): the README's markdown tables (ranked OPEN clusters with sites and yields,
the first clusters of the fail list, the covered clusters). Args: <work dir> <map dir>"""
import os, sys, json, csv, collections, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import rekey
W, M = sys.argv[1:3]
cid = json.load(open(f'{W}/ids.json'))['cid']
CI = {r['cluster_id']: r for r in csv.DictReader(open(f'{M}/cluster_index.csv'))}
rows = {}
for l in open(f'{W}/corpus.jsonl'):
    r = json.loads(l); rows[(r['corpus'], r['mode'], r['test'])] = {cid[rekey(x)] for x in r['rows']}
iscov = lambda c: CI[c]['coverage'].startswith('COVERED')
AB = {c for c in CI if iscov(c)}
yld = lambda S: sum(1 for s in rows.values() if s <= S)
base = yld(AB)
def site(c, n=200):
    s = CI[c]['site']; note = ''
    m = re.search(r' \[(DECODED[^\]]*|NOTE[^\]]*)\]', s)
    if m: note = ' — ' + m.group(1)[:160]; s = s[:m.start()] + s[m.end():]
    s = s.replace(' [r11u138map pin]', ' (r11u138map pin)')
    return (s[:n] + note).replace('|', '/')
def ex(c):
    e = CI[c]['example']; return e[:120].replace('|', '/')
key = lambda c: '`' + CI[c]['key'].replace('|', '\\|') + '`'
P = print
P('### ranked OPEN clusters (top 60 by corpus row-modes)\n')
P('| rank | cluster | rows sl/u2r | tests | first in | probe | after nb | alone on pairs | ground | coverage | key | example (row #golden/#ours type name golden / ours) | site (mint: function (file, nearest law) < caller < caller) |')
P('|---|---|---|---|---|---|---|---|---|---|---|---|---|')
opn = sorted([c for c in CI if not iscov(c) and int(CI[c]['rows']) > 0], key=lambda c: int(CI[c]['rank']))
for c in opn[:60]:
    r = CI[c]
    P(f"| {r['rank']} | {c} | {r['rows']} {r['rows_surelog']}/{r['rows_uhdm2rtlil']} | {r['tests']} | {r['first_in_rows']} | {r['probe_cases']} | {r['rows_after_nb']} | {r['alone_on_top_of_pairs_after_nb']} | {r['ground']} | {r['coverage'][:60].replace('|','/')} | {key(c)} | {ex(c)} | {site(c)} |")
P('\n### the first clusters of the fail list (top 30)\n')
FL = list(csv.DictReader(open(f'{M}/fail_list.csv')))
fc = collections.Counter(r['first_cluster'] for r in FL)
P('| first cluster | row-modes it heads | after nb | coverage | key | site |'); P('|---|---|---|---|---|---|')
for c, n in fc.most_common(30):
    P(f"| {c} | {n} | {CI[c]['first_in_after_nb']} | {CI[c]['coverage'][:70]} | {key(c)} | {site(c, 150)} |")
P(f'\n{len(fc)} distinct first clusters.')
P('\n### covered clusters (the live pairs)\n')
P('| cluster | rows sl/u2r | tests | first in | probe | alone | coverage | key | site |'); P('|---|---|---|---|---|---|---|---|---|')
for c in sorted([c for c in CI if iscov(c)], key=lambda c: int(CI[c]['rank'])):
    r = CI[c]
    P(f"| {c} | {r['rows']} {r['rows_surelog']}/{r['rows_uhdm2rtlil']} | {r['tests']} | {r['first_in_rows']} | {r['probe_cases']} | {r['alone_yield_rows']} | {r['coverage'][:110]} | {key(c)} | {site(c, 150)} |")
