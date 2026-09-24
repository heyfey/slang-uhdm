#!/usr/bin/env python3
# probe_movers2.py <wdA> <wdB> <out> : strict-record movers between two probe sweeps (worktree paths differ)
import sys, os, subprocess, re, tempfile
from concurrent.futures import ThreadPoolExecutor
sys.path.insert(0, '/tmp/wt_v11u131pris/scripts'); os.chdir('/tmp/wt_v11u131pris')
import check_probe as cp, verify_golden as vg
SC='/tmp/v11u131_bin/strictcmp'; D='/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump'
A, B, OUT = sys.argv[1:4]
def recs(g, o, tag):
    d = tempfile.mkdtemp(prefix='v11u131_pm')
    r = subprocess.run([SC, '--dump-a', d+'/a', '--dump-b', d+'/b', g, o], capture_output=True, text=True)
    v = (r.stdout.strip().splitlines() or [''])[-1]
    if os.path.exists(d+'/b'):
        GA = open(d+'/a').read().splitlines(); X = open(d+'/b').read().splitlines()
    else:
        t = subprocess.run([D, o], capture_output=True, text=True, errors='replace').stdout
        t = re.sub(r', id:\d+', '', t); t = re.sub(r'/tmp/wt_v11u131(pris)?/', '/W/', t); t = re.sub(r'/tmp/v11u131_wd./', '/WD/', t)
        GA = None; X = t.splitlines()
    subprocess.run(['rm', '-rf', d]); return GA, X, v
def one(rel):
    f = rel.replace('/', '__') + '.uhdm'
    a, b = os.path.join(A, 'probe', f), os.path.join(B, 'probe', f)
    g = vg.cache_load(cp.cache_dir(rel))[1]
    GA, XA, va = recs(g, a, 'a'); GB, XB, vb = recs(g, b, 'b')
    if XA == XB and va == vb: return None
    if GA is None or GB is None: return f'{rel} :: STAGE1-DIFF {va} -> {vb}'
    worse = better = 0
    for i in range(min(len(GA), len(XA), len(XB))):
        pm = GA[i] == XA[i]; lm = GA[i] == XB[i]
        if pm and not lm: worse += 1
        elif lm and not pm: better += 1
    return f'{rel} :: {"WORSE" if worse else "OK"} better={better} worse={worse} len={len(GA)},{len(XA)},{len(XB)} | {va} -> {vb}'
with ThreadPoolExecutor(6) as ex:
    res = [r for r in ex.map(one, cp.cases(None)) if r]
open(OUT, 'w').write('\n'.join(res) + '\n')
print('MOVERS', len(res), 'WORSE', sum('WORSE' in r for r in res), 'STAGE1', sum('STAGE1' in r for r in res))
