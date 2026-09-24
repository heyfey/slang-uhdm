#!/usr/bin/env python3
# probe_strict.py <probe workdir> <out.tsv> : per-case strict verdict (golden from cache)
import sys, os, subprocess, concurrent.futures as cf
sys.path.insert(0, '/tmp/wt_r11u125/scripts')
import check_probe as cp
wd, out = sys.argv[1], sys.argv[2]
S = '/tmp/r11u125_bin/strictcmp.bin'
rels = cp.cases(None) if cp.cases.__code__.co_argcount else cp.cases()
def one(rel):
    g = os.path.join(cp.cache_dir(rel), 'golden.uhdm')
    o = os.path.join(wd, rel.replace('/', '__') + '.uhdm')
    if not os.path.exists(o) or not os.path.exists(g):
        return rel, 'MISSING'
    r = subprocess.run([S, '--max', '1', g, o], capture_output=True, text=True)
    lines = r.stdout.strip().splitlines() or ['']
    od = ''
    for l in lines:
        if 'objects_differing=' in l:
            od = l.split('objects_differing=')[1].split()[0]
    return rel, lines[-1] + ('(' + od + ')' if od else '')
with cf.ThreadPoolExecutor(3) as ex, open(out, 'w') as f:
    for rel, v in ex.map(one, rels):
        f.write(f'{rel}\t{v}\n')
