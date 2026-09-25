#!/usr/bin/env python3
"""r11u165: the README tables from cluster_index.csv / fail_list.csv (report8.py's output).
Args: <map out dir> <section: t1|t4|probeonly|covered|newc>"""
import csv, sys, collections, re
OUT, SEC = sys.argv[1:3]
CI = {r['cluster_id']: r for r in csv.DictReader(open(f'{OUT}/cluster_index.csv'))}
FL = list(csv.DictReader(open(f'{OUT}/fail_list.csv')))
esc = lambda s: str(s).replace('|', '\\|')
def short_site(s, n=110):
    s = re.sub(r' \[r11u1\d\dmap pin[^\]]*\]', '', s); s = re.sub(r' \[(NOTE|DECODED)[^\]]*\]', '', s)
    return esc(s[:n])
def short_cov(s, n=60):
    s = s.replace('OPEN (map 7 listed it: ', 'OPEN (map 7 ').replace('; passes 152-163 left it)', ')')
    return esc(s[:n])
isopen = lambda r: not r['coverage'].startswith('COVERED')
if SEC == 't1':
    rs = [r for r in CI.values() if isopen(r) and int(r['rows_after_pairs']) > 0]
    rs.sort(key=lambda r: (-int(r['rows_after_pairs']), -int(r['alone_on_top_of_pairs']), -int(r['first_in_after_pairs']), -int(r['probe_after_law']), r['cluster_id']))
    print('| # | cluster | rows left (f2f2d30b) | sl/u2r | tests | families | heads | alone | probe (after dec) | ground | status | key | site (mint < caller < caller) |')
    print('|---|---|---|---|---|---|---|---|---|---|---|---|---|')
    for i, r in enumerate(rs[:int(sys.argv[3]) if len(sys.argv) > 3 else 45]):
        print(f"| {i+1} | {r['cluster_id']} | {r['rows_after_pairs']} ({r['rows']}) | {r['rows_surelog']}/{r['rows_uhdm2rtlil']} | {r['tests']} | {r['families'] or '-'} | {r['first_in_after_pairs']} | {r['alone_on_top_of_pairs']} | {r['probe_after_law']} | {r['ground']} | {short_cov(r['coverage'])} | `{esc(r['key'])}` | {short_site(r['site'])} |")
elif SEC == 'nonfam':
    fams = ('UVM', 'Earlgrey', 'Rggen', 'BlackBePipeInt', 'Scr1', 'ApbSlave')
    rs = [r for r in CI.values() if isopen(r) and int(r['rows_after_pairs']) > 0 and (set(r['families'].split()) - set(fams) or not r['families']) and not all(t in ('FENCED',) for t in r['example_tests'].split())]
    # rows outside the big families: count them from fail_list
    big = {'MiniAmiq', 'SeqDriver', 'SimpleUVM', 'Scoreboard', 'BuildUVMPkg', 'Earlgrey_0_1', 'Rggen', 'BlackBePipeInt', 'Scr1SvTests', 'ApbSlave'}
    cnt = collections.Counter(); heads = collections.Counter()
    for f in FL:
        if f['test'] in big or f['clears_after_decodes_and_pair_b'] != 'no': continue
        for c in f['open_clusters_after_pairs'].split(): cnt[c] += 1
        if f['first_cluster_after_decodes'] in CI: heads[f['first_cluster_after_decodes']] += 1
    rs = sorted((c for c in cnt if c in CI), key=lambda c: (-cnt[c], -heads[c], c))
    print('| # | cluster | rows outside the big families (all rows) | heads there | alone | ground | status | key | site |')
    print('|---|---|---|---|---|---|---|---|---|')
    for i, c in enumerate(rs[:int(sys.argv[3]) if len(sys.argv) > 3 else 40]):
        r = CI[c]
        print(f"| {i+1} | {c} | {cnt[c]} ({r['rows_after_pairs']}) | {heads[c]} | {r['alone_on_top_of_pairs']} | {r['ground']} | {short_cov(r['coverage'], 70)} | `{esc(r['key'])}` | {short_site(r['site'], 100)} |")
elif SEC == 'newc':
    for c, r in sorted(CI.items()):
        if c >= 'N2400':
            print(f"| {c} | {r['rows']} -> {r['rows_after_law']} | {r['probe_cases']} -> {r['probe_after_law']} | {r['ground']} | `{esc(r['key'])}` | {esc(r['example'][:110])} | {short_site(r['site'], 120)} |")
