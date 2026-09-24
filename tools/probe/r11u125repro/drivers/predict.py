#!/usr/bin/env python3
# predict.py <wdP> <out.tsv>: from the PRISTINE databases (vs golden) name the rows each r11u125 law
# should move: GV = a gen_scope `parameter` located at column 0 with no file (genvar);
# FILE = any located object whose file differs from golden's (empty or another buffer);
# INC = an object on line 1 of an included file whose col differs from golden's.
import sys, os, subprocess, glob, re, concurrent.futures as cf
wdP, out = sys.argv[1:3]
S = '/tmp/r11u125_bin/strictcmp.bin'
tmp = '/tmp/r11u125_scratch/pred'; os.makedirs(tmp, exist_ok=True)
jobs = sorted(glob.glob(f'{wdP}/*/*/*/slang.uhdm'))
def gold(d):
    c = open(d + '/cmds.txt').read()
    mm = re.search(r'golden cache hit (\S+)\)', c)
    return (mm.group(1) + '/golden.uhdm') if mm else d + '/slpp_all/surelog.uhdm'
def recs(p): return [(l.rstrip('\n').split('\t') + ['']*14)[:14] for l in open(p)]
key = lambda r: '\t'.join(r[:4])
def one(p):
    d = os.path.dirname(p); rel = os.path.relpath(p, wdP)
    base = tmp + '/' + rel.replace('/', '__')
    subprocess.run([S, '--max', '1', '--dump-a', base + '.g', '--dump-b', base + '.p', gold(d), p], capture_output=True)
    if not os.path.exists(base + '.p') or not os.path.exists(base + '.g'):
        return rel, 'NODUMP', 0, 0, 0
    G, P = recs(base + '.g'), recs(base + '.p')
    fa, fb = base + '.ka', base + '.kb'
    open(fa, 'w').write('\n'.join(key(r) for r in P) + '\n'); open(fb, 'w').write('\n'.join(key(r) for r in G) + '\n')
    dd = subprocess.run(['diff', '--unchanged-line-format=U\n', '--old-line-format=O\n', '--new-line-format=N\n', fa, fb], capture_output=True, text=True).stdout.split()
    a = b = 0; gv = fl = inc = 0
    parents = []
    for op in dd:
        if op == 'U':
            pr, gr = P[a], G[b]
            if pr[1] == 'parameter' and pr[5] == '' and pr[7] == '0' and pr[6] != '0': gv += 1
            if pr[5] != gr[5] and pr[6] != '0': fl += 1
            if pr[6] == '1' and pr[7] != gr[7] and pr[5] and not pr[5].endswith(('dut.sv',)): inc += 1
            a += 1; b += 1
        elif op == 'O':
            pr = P[a]
            if pr[1] == 'parameter' and pr[5] == '' and pr[7] == '0' and pr[6] != '0': gv += 1
            a += 1
        else: b += 1
    for s in ('.g', '.p', '.ka', '.kb'):
        try: os.remove(base + s)
        except: pass
    return rel, 'OK', gv, fl, inc
with cf.ThreadPoolExecutor(3) as ex, open(out, 'w') as f:
    for r in ex.map(one, jobs):
        f.write('\t'.join(map(str, r)) + '\n'); f.flush()
