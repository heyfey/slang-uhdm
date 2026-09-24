#!/usr/bin/env python3
# prefix.py <census.tsv> <pristine wd> <law wd> -> per changed (non-converted) row: the pristine walk's
# first differing record P1, the law's L1, and whether any record BEFORE P1 (which matched golden in the
# pristine walk) differs from golden in the law walk (REGRESS) - else the new differences are at or beyond
# the pristine divergence point (the walk got further: UNMASK), or strictly fewer (IMPROVE).
import sys, os, re, glob, subprocess
sys.path.insert(0, '/tmp/wt_r11u137/scripts')
import verify_golden as vg, check_probe as cp
SCX = '/tmp/r11u137_bin/strictcmp_x'
cen, P, L = sys.argv[1:4]
T = '/tmp/r11u137_scr/prefix'; os.makedirs(T, exist_ok=True)
def golden_of_rowdir(d):
    t = open(os.path.join(d, 'cmds.txt')).read()
    m = re.search(r'golden cache hit (\S+?)\)', t) or re.search(r'golden cache hit (\S+)', t)
    g = m.group(1) if m else None
    if g and os.path.isdir(g):
        gg = glob.glob(os.path.join(g, '*.uhdm')); g = gg[0] if gg else None
    return g
def run(g, o, tag):
    a, b = f'{T}/{tag}.a', f'{T}/{tag}.b'
    r = subprocess.run([SCX, '--max', '100000', '--dump-a', a, '--dump-b', b, g, o], capture_output=True, text=True, timeout=1200)
    idx = [int(m.group(1)) for m in re.finditer(r'^#(\d+) ', r.stdout, re.M)]
    run.div = 'walk diverged' in r.stdout
    A = [l.split('\x1f')[0] for l in open(a, encoding='utf-8', errors='replace')]
    B = [l.split('\x1f')[0] for l in open(b, encoding='utf-8', errors='replace')]
    return idx, A, B
for line in open(cen):
    if line.startswith('#'): continue
    corpus, key, a, b, tag = line.rstrip('\n').split('\t')
    if tag == 'TURNED_EQUAL': continue
    if corpus == 'probe':
        rel = key; h = cp.vg.cache_load(cp.cache_dir(rel)); g = h[1] if h else None
        po = f'{P}/probe/' + rel.replace('/', '__') + '.uhdm'; lo = f'{L}/probe/' + rel.replace('/', '__') + '.uhdm'
    else:
        name, mode = key.split('/')
        pd = [d for d in glob.glob(f'{P}/{corpus}/{mode}/{name}-*') if re.fullmatch(re.escape(name)+r'-[0-9a-f]{8}', os.path.basename(d))]
        ld = [d for d in glob.glob(f'{L}/{corpus}/{mode}/{name}-*') if re.fullmatch(re.escape(name)+r'-[0-9a-f]{8}', os.path.basename(d))]
        g = golden_of_rowdir(pd[0]); po = pd[0] + '/slang.uhdm'; lo = ld[0] + '/slang.uhdm'
    ip, GA, PB = run(g, po, 'p'); pdiv = run.div
    il, GA2, LB = run(g, lo, 'l'); ldiv = run.div
    # records the pristine walk matched (before its structural divergence, if any)
    # that the law walk does not: the regression candidates
    D = ip[-1] if (pdiv and ip) else 10**12
    newbad = [i for i in il if i not in set(ip) and i < D]
    p1 = ip[0] if ip else None; l1 = il[0] if il else None
    reg = [i for i in il if p1 is not None and i < p1]
    verdict = 'REGRESS' if reg else ('NEWDIFF' if newbad else ('IMPROVE' if len(il) < len(ip) and set(il) <= set(ip) else 'UNMASK'))
    print(f'{corpus}\t{key}\t{tag}\tP1={p1}\tL1={l1}\tnP={len(ip)}\tnL={len(il)}\t{verdict}' + f'\tpdiv={int(pdiv)} ldiv={int(ldiv)} newbad={len(newbad)}' + (f'\tfirst=#{(reg or newbad)[0]} G[{GA2[(reg or newbad)[0]][:100]}] P[{PB[(reg or newbad)[0]][:100] if (reg or newbad)[0] < len(PB) else ""}] L[{LB[(reg or newbad)[0]][:100]}]' if (reg or newbad) else ''))
