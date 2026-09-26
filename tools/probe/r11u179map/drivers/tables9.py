#!/usr/bin/env python3
"""r11u179: the README tables from cluster_index.csv / fail_list.csv / probe_fail_list.csv (report9.py's output).
Args: <map dir> <section: t1|nonfam|newc|fail|pfirst|ground> [n]"""
import csv, sys, collections, re
OUT, SEC = sys.argv[1:3]; N = int(sys.argv[3]) if len(sys.argv) > 3 else 40
CI = {r['cluster_id']: r for r in csv.DictReader(open(f'{OUT}/cluster_index.csv'))}
FL = list(csv.DictReader(open(f'{OUT}/fail_list.csv')))
PF = list(csv.DictReader(open(f'{OUT}/probe_fail_list.csv')))
esc = lambda s: str(s).replace('|', '\\|')
def short_site(s, n=110):
    s = re.sub(r' \[r11u1\d\d(map)? pin[^\]]*\]', '', s); s = re.sub(r' \[(NOTE|DECODED)[^\]]*\]', '', s)
    s = re.sub(r' \[r11u165map pin \(other example\)[^\]]*\]', '', s)
    return esc(s[:n])
def short_cov(s, n=60):
    s = re.sub(r' \[r11u175 reduces it: rows (\d+)->(\d+), probe (\d+)->(\d+)\]', lambda m: f' [r11u175: rows {m.group(1)}->{m.group(2)}]' if m.group(1) != m.group(2) else '', s)
    s = s.replace('OPEN (map 8 listed it: ', 'OPEN (map 8 ').replace('; passes 164-174 left it)', ')')
    return esc(s[:n])
isopen = lambda r: not r['coverage'].startswith('COVERED')
BIG = {'MiniAmiq', 'SeqDriver', 'SimpleUVM', 'Scoreboard', 'BuildUVMPkg', 'Earlgrey_0_1', 'Rggen', 'BlackBePipeInt', 'Scr1SvTests', 'ApbSlave', 'SVSwitch'}
if SEC == 't1':
    rs = [r for r in CI.values() if isopen(r) and int(r['rows_after_pairs']) > 0]
    rs.sort(key=lambda r: (-int(r['rows_after_pairs']), -int(r['alone_on_top_of_pairs']), -int(r['first_in_after_pairs']), -int(r['probe_after_law']), r['cluster_id']))
    print('| # | cluster | rows left (5e8d08d9) | sl/u2r | tests | families | first-open heads | alone | probe (after r11u175) | ground | status | key | site (mint < caller < caller) |')
    print('|---|---|---|---|---|---|---|---|---|---|---|---|---|')
    for i, r in enumerate(rs[:N]):
        print(f"| {i+1} | {r['cluster_id']} | {r['rows_after_pairs']} ({r['rows']}) | {r['rows_surelog']}/{r['rows_uhdm2rtlil']} | {r['tests']} | {r['families'] or '-'} | {r['first_in_after_pairs']} | {r['alone_on_top_of_pairs']} | {r['probe_after_law']} | {r['ground']} | {short_cov(r['coverage'])} | `{esc(r['key'])}` | {short_site(r['site'])} |")
elif SEC in ('nonfam', 'ground'):
    cnt = collections.Counter(); heads = collections.Counter()
    for f in FL:
        if f['clears'] != 'no': continue
        if SEC == 'nonfam' and f['test'] in BIG: continue
        for c in f['open_clusters_after_pairs'].split(): cnt[c] += 1
        heads[f['first_open_cluster_after_pairs']] += 1
    g = sys.argv[4] if SEC == 'ground' else None
    rs = sorted((c for c in cnt if c in CI and (g is None or CI[c]['ground'] == g)), key=lambda c: (-cnt[c], -heads[c], -int(CI[c]['probe_after_law']), c))
    print(f"| # | cluster | rows{' outside the big families' if SEC == 'nonfam' else ''} (tests) | first-open heads | alone | probe | ground | status | key | site |")
    print('|---|---|---|---|---|---|---|---|---|---|')
    for i, c in enumerate(rs[:N]):
        r = CI[c]
        print(f"| {i+1} | {c} | {cnt[c]} ({r['tests']}) | {heads[c]} | {r['alone_on_top_of_pairs']} | {r['probe_after_law']} | {r['ground']} | {short_cov(r['coverage'], 60)} | `{esc(r['key'])}` | {short_site(r['site'], 100)} |")
elif SEC == 'newc':
    for c, r in sorted(CI.items()):
        if r['map8_rows_f2f2d30b'] == '-':
            print(f"| {c} | {r['rows']} -> {r['rows_after_law']} | {r['probe_cases']} -> {r['probe_after_law']} | {r['ground']} | `{esc(r['key'])}` | {esc(r['example'][:110])} | {short_site(r['site'], 120)} |")
elif SEC == 'fail':
    by = collections.OrderedDict()
    for f in FL: by.setdefault((f['corpus'], f['test']), []).append(f)
    print('| corpus | test | cell d / t | clusters d/t | first cluster (ground) | first site | after r11u175 | first open after the pairs | open after pairs | clears | downstream |')
    print('|---|---|---|---|---|---|---|---|---|---|---|')
    for (c, t), fs in sorted(by.items(), key=lambda x: (x[0][0], min(int(f['clusters']) for f in x[1]), x[0][1])):
        d = {f['mode']: f for f in fs}; f0 = d.get('default') or d['testflags']
        cell = ' / '.join(d[m]['strict'] if m in d else '-' for m in ('default', 'testflags'))
        ncl = '/'.join(d[m]['clusters'] if m in d else '-' for m in ('default', 'testflags'))
        aft = ' / '.join(d[m]['strict_after_r11u175'] if m in d else '-' for m in ('default', 'testflags'))
        if aft.split(' / ')[0] == cell.split(' / ')[0] and len(set(aft.split(' / '))) <= 2 and aft == cell: aft = 'same'
        fo = f0['first_open_cluster_after_pairs']; oc = '/'.join(str(len(d[m]['open_clusters_after_pairs'].split())) if m in d else '-' for m in ('default', 'testflags'))
        cl = '; '.join(sorted({d[m]['clears'] for m in d}))
        print(f"| {c[:3]} | {t} | {cell} | {ncl} | {f0['first_cluster']} ({f0['first_ground']}) | {short_site(f0['first_site'], 70)} | {aft} | {fo} | {oc} | {cl} | {f0['downstream'] or '-'} |")
elif SEC == 'pfirst':
    c = collections.Counter(r['first_cluster'] for r in PF)
    print('| first cluster | probe cases it heads | clears (r11u175 / pairs) | ground | status | key | top laws |')
    print('|---|---|---|---|---|---|---|')
    for k, n in c.most_common(N):
        r = CI[k]; cl = collections.Counter(p['clears'].split(' (')[0] + ('' if p['clears'] == 'no' else ' ' + p['clears'].split('(')[1].split(',')[0]) for p in PF if p['first_cluster'] == k)
        print(f"| {k} | {n} | {', '.join(f'{a} {b}' for a, b in cl.most_common())} | {r['ground']} | {short_cov(r['coverage'], 50)} | `{esc(r['key'])}` | {esc(r['probe_laws'][:70])} |")
elif SEC == 'greedy':
    import json
    G = json.load(open(sys.argv[4]))[sys.argv[5]]
    base = int(sys.argv[6]); cum = base; tt = set()
    print('| step | clusters added | +row-modes | cum row-modes | rows | ground(s) | site of the first |')
    print('|---|---|---|---|---|---|---|')
    for i, s in enumerate(G):
        cum += s['gain']
        rows = ' '.join(k.split('|')[2] + '/' + k.split('|')[1][0] + ('/u2r' if k.startswith('uhdm2rtlil') else '') for k in s['rows'])
        print(f"| {i+1} | {' + '.join(s['add'])} | {s['gain']} | {cum} | {rows} | {'+'.join(sorted({CI[c]['ground'] for c in s['add']}))} | {short_site(CI[s['add'][0]]['site'], 110)} |")
