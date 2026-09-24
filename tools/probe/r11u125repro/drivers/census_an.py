#!/usr/bin/env python3
# census_an.py <census wd> <pristine wd> : per census site, golden file vs pristine file on marked objects
import sys, os, subprocess, glob, collections, csv, difflib, concurrent.futures as cf
wdC, wdP = sys.argv[1], sys.argv[2]
S = '/tmp/r11u125_bin/strictcmp.bin'
tmp = '/tmp/r11u125_scratch/cen'
os.makedirs(tmp, exist_ok=True)
jobs = []
for corpus in ('surelog', 'uhdm2rtlil'):
    for row in csv.reader(open(f'{wdC}/{corpus}.csv')):
        if len(row) < 3 or row[2] != 'CMP_EQUAL': continue
        t, m = row[0], row[1]
        dc = glob.glob(f'{wdC}/{corpus}/{m}/{t}-*')
        dp = glob.glob(f'{wdP}/{corpus}/{m}/{t}-*')
        if not dc or not dp: continue
        jobs.append((corpus, m, t, dc[0], dp[0]))
def gold(d):
    c = open(d + '/cmds.txt').read()
    import re
    mm = re.search(r'golden cache hit (\S+)\)', c)
    return (mm.group(1) + '/golden.uhdm') if mm else d + '/slpp_all/surelog.uhdm'
def recs(path):
    return [l.rstrip('\n').split('\t') for l in open(path)]
def one(j):
    corpus, m, t, dc, dp = j
    g = gold(dc)
    base = f'{tmp}/{corpus}.{m}.{t}'
    subprocess.run([S, '--max', '1', '--dump-a', base + '.g', '--dump-b', base + '.c', g, dc + '/slang.uhdm'], capture_output=True)
    if not os.path.exists(base + '.c'): return []
    C = recs(base + '.c')
    marks = [i for i, r in enumerate(C) if len(r) > 5 and r[5].startswith('CENSUS_')]
    if not marks:
        for s in ('.g', '.c'):
            try: os.remove(base + s)
            except: pass
        return []
    subprocess.run([S, '--max', '1', '--dump-a', base + '.g2', '--dump-b', base + '.p', g, dp + '/slang.uhdm'], capture_output=True)
    G = recs(base + '.g'); P = recs(base + '.p')
    out = []
    # pair census->pristine by index (structure identical by construction)
    key = lambda r: tuple(r[:4])
    cmap = {}
    if len(C) == len(G) and all(key(C[i]) == key(G[i]) for i in range(len(C))):
        cmap = {i: i for i in range(len(C))}
    else:
        # pair by key-sequence through GNU diff
        fa = base + '.kc'; fb = base + '.kg'
        open(fa, 'w').write('\n'.join('\t'.join(key(r)) for r in C) + '\n')
        open(fb, 'w').write('\n'.join('\t'.join(key(r)) for r in G) + '\n')
        d = subprocess.run(['diff', '--unchanged-line-format=U\n', '--old-line-format=O\n', '--new-line-format=N\n', fa, fb], capture_output=True, text=True).stdout.split()
        a = b = 0
        for op in d:
            if op == 'U': cmap[a] = b; a += 1; b += 1
            elif op == 'O': a += 1
            else: b += 1
    for i in marks:
        site = C[i][5]
        pf = P[i][5] if i < len(P) and key(P[i]) == key(C[i]) else '?'
        gi = cmap.get(i)
        gf = G[gi][5] if gi is not None else 'UNPAIRED'
        same_span = gi is not None and G[gi][6:10] == C[i][6:10]
        out.append((site, corpus, m, t, C[i][1], gf, pf, same_span))
    return out
res = []
with cf.ThreadPoolExecutor(3) as ex:
    for r in ex.map(one, jobs): res.extend(r)
with open('/tmp/r11u125_scratch/census_rows.tsv', 'w') as f:
    for r in res: f.write('\t'.join(map(str, r)) + '\n')
agg = collections.Counter()
rows = collections.defaultdict(set)
for site, corpus, m, t, typ, gf, pf, ss in res:
    gcls = 'g-empty' if gf == '' else ('g-UNPAIRED' if gf == 'UNPAIRED' else 'g-file')
    pcls = 'p-empty' if pf == '' else ('p-?' if pf == '?' else 'p-file')
    agg[(site, typ, gcls, pcls, ss)] += 1
    rows[(site, typ, gcls, pcls, ss)].add(f'{corpus}/{m}/{t}')
for k, v in sorted(agg.items()):
    ex = sorted(rows[k])
    print(v, len(ex), *k, ex[:3], sep='\t')
