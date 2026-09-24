#!/usr/bin/env python3
# objcheck.py <wdP> <wdL> <out.tsv> : per row-mode whose slang.uhdm bytes differ,
# per object/field: improved (law==golden, pristine!=golden), worsened (pristine==golden, law!=golden), neutral.
import sys, os, subprocess, glob, csv, re, filecmp, concurrent.futures as cf
wdP, wdL, out = sys.argv[1:4]
S = '/tmp/r11u125_bin/strictcmp.bin'
tmp = '/tmp/r11u125_scratch/oc_' + os.path.basename(wdL.rstrip('/'))
os.makedirs(tmp, exist_ok=True)
F = 'depth type name defname fullname file line col endline endcol decompile size value consttype'.split()
jobs = []
for corpus in ('surelog', 'uhdm2rtlil'):
    stL = {(r[0], r[1]): r for r in csv.reader(open(f'{wdL}/{corpus}.csv')) if len(r) > 5}
    for (t, m), r in stL.items():
        if r[2] != 'CMP_EQUAL': continue
        dl = glob.glob(f'{wdL}/{corpus}/{m}/{t}-*'); dp = glob.glob(f'{wdP}/{corpus}/{m}/{t}-*')
        if not dl or not dp: continue
        jobs.append((corpus, m, t, dp[0], dl[0]))
def gold(d):
    c = open(d + '/cmds.txt').read()
    mm = re.search(r'golden cache hit (\S+)\)', c)
    return (mm.group(1) + '/golden.uhdm') if mm else d + '/slpp_all/surelog.uhdm'
def recs(p): return [l.rstrip('\n').split('\t') for l in open(p)]
key = lambda r: '\t'.join(r[:4])
def pair(A, B, base):
    if len(A) == len(B) and all(key(A[i]) == key(B[i]) for i in range(len(A))):
        return {i: i for i in range(len(A))}
    fa, fb = base + '.ka', base + '.kb'
    open(fa, 'w').write('\n'.join(key(r) for r in A) + '\n'); open(fb, 'w').write('\n'.join(key(r) for r in B) + '\n')
    d = subprocess.run(['diff', '--unchanged-line-format=U\n', '--old-line-format=O\n', '--new-line-format=N\n', fa, fb], capture_output=True, text=True).stdout.split()
    m = {}; a = b = 0
    for op in d:
        if op == 'U': m[a] = b; a += 1; b += 1
        elif op == 'O': a += 1
        else: b += 1
    return m
def one(j):
    corpus, m, t, dp, dl = j
    if filecmp.cmp(dp + '/slang.uhdm', dl + '/slang.uhdm', shallow=False):
        return (corpus, m, t, 'BYTES_SAME', 0, 0, 0, '', '')
    g = gold(dl); base = f'{tmp}/{corpus}.{m}.{t}'
    subprocess.run([S, '--max', '1', '--dump-a', base + '.g', '--dump-b', base + '.p', g, dp + '/slang.uhdm'], capture_output=True)
    subprocess.run([S, '--max', '1', '--dump-a', base + '.g2', '--dump-b', base + '.l', g, dl + '/slang.uhdm'], capture_output=True)
    try:
        G, P, L = recs(base + '.g'), recs(base + '.p'), recs(base + '.l')
    except Exception as e:
        return (corpus, m, t, 'NODUMP', 0, 0, 0, '', '')
    struct = 'SAME_WALK' if len(P) == len(L) and all(key(P[i]) == key(L[i]) for i in range(len(P))) else 'WALK_CHANGED'
    pl = pair(P, L, base + 'pl') if struct != 'SAME_WALK' else {i: i for i in range(len(P))}
    pg = pair(P, G, base + 'pg')
    lg = pair(L, G, base + 'lg')
    imp = wor = neu = 0; ex = ''; exn = ''
    for i, k in pl.items():
        p, l = P[i], L[k]
        gi = lg.get(k)
        gr = G[gi] if gi is not None else None
        for fi in range(len(F)):
            pv = p[fi] if fi < len(p) else ''; lv = l[fi] if fi < len(l) else ''
            if pv == lv: continue
            gv = (gr[fi] if fi < len(gr) else '') if gr else None
            if gv is None:
                neu += 1
                if not exn: exn = f'#{k} {F[fi]} p={pv} l={lv} g=UNPAIRED {l[1]} {l[2]}'
            elif lv == gv: imp += 1
            elif pv == gv:
                wor += 1
                if not ex: ex = f'#{k} {F[fi]} p={pv} l={lv} g={gv} {l[1]} {l[2]}'
            else:
                neu += 1
                if not exn: exn = f'#{k} {F[fi]} p={pv} l={lv} g={gv} {l[1]} {l[2]}'
    for s in ('.g', '.g2', '.p', '.l'):
        try: os.remove(base + s)
        except: pass
    return (corpus, m, t, struct, imp, wor, neu, ex, exn)
with cf.ThreadPoolExecutor(3) as ex, open(out, 'w') as f:
    for r in ex.map(one, jobs):
        f.write('\t'.join(map(str, r)) + '\n'); f.flush()
