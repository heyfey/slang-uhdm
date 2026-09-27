#!/usr/bin/env python3
"""r11u183: is every probe CHANGE line of a law sweep an improvement?  For each case a sweep log names as a
CHANGE (or CONVERSION), the order-blind record distance (obdist: depth column dropped, multiset difference of
uhdm-strictcmp --dump-a/-b records; dist = ours-not-in-golden, rev = golden-not-in-ours) of the pristine sweep's
database and of the law sweep's database against the case's cached golden (check_probe.cache_dir).
usage: chgdist.py <law sweep log> <pristine workdir> <law workdir>   (tests/probe cases only; no corpus rows)"""
import sys, os, re, subprocess, collections, tempfile
sys.path.insert(0, '/tmp/wt_r11u183/scripts')
import check_probe as cp, verify_golden as vg
SCMP = os.environ.get('SCMP', '/tmp/r11u183_bin/uhdm-strictcmp')
log, P, L = sys.argv[1:4]
rels = [m.group(2) for m in (re.match(r'^(CHANGE|CONVERSION) (\S+) STRICT', l) for l in open(log)) if m and '/' in m.group(2)]
T = tempfile.mkdtemp(prefix='r11u183_chg_', dir='/tmp')
def recs(g, u, tag):
    a, b = os.path.join(T, 'a'), os.path.join(T, tag)
    subprocess.run([SCMP, '--max', '0', '--dump-a', a, '--dump-b', b, g, u], capture_output=True)
    ca = collections.Counter(l.split('\t', 1)[1] for l in open(a) if '\t' in l)
    cb = collections.Counter(l.split('\t', 1)[1] for l in open(b) if '\t' in l)
    return sum((cb - ca).values()), sum((ca - cb).values())
worse = 0
for rel in rels:
    hit = vg.cache_load(cp.cache_dir(rel)); g = hit[1] if hit else None
    fn = rel.replace('/', '__') + '.uhdm'
    pu, lu = os.path.join(P, 'probe', fn), os.path.join(L, 'probe', fn)
    if not (g and os.path.exists(pu) and os.path.exists(lu)):
        print('MISSING', rel); continue
    pd, pr = recs(g, pu, 'p'); ld, lr = recs(g, lu, 'l')
    v = 'BETTER' if ld + lr < pd + pr else ('SAME' if ld + lr == pd + pr else 'WORSE')
    worse += v == 'WORSE'
    print(f'{v}\t{rel}\tpristine dist={pd} rev={pr} total={pd+pr}\tlaw dist={ld} rev={lr} total={ld+lr}')
print('CASES', len(rels), 'WORSE', worse)
