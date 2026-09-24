#!/usr/bin/env python3
# per-case probe strict column for two workdirs (pristine, law): only cases whose bytes differ are re-judged.
import sys, os, subprocess, filecmp
sys.path.insert(0, '/tmp/wt_v11u124/scripts')
import check_probe as cp, verify_golden as vg
from concurrent.futures import ThreadPoolExecutor
P, L = sys.argv[1], sys.argv[2]
rels = []
for root, dirs, files in os.walk(cp.ROOT):
    if 'dut.sv' in files:
        rels.append(os.path.relpath(root, cp.ROOT))
rels.sort()
def one(rel):
    n = rel.replace('/', '__') + '.uhdm'
    a, b = os.path.join(P, n), os.path.join(L, n)
    if filecmp.cmp(a, b, shallow=False):
        return rel, None, None
    hit = vg.cache_load(cp.cache_dir(rel)); g = hit[1]
    sa = vg.strict_verdict(g, a, 300); sb = vg.strict_verdict(g, b, 300)
    ca = subprocess.run([vg.UHDM_CMP, g, a], capture_output=True).returncode
    cb = subprocess.run([vg.UHDM_CMP, g, b], capture_output=True).returncode
    return rel, (ca, sa), (cb, sb), g
with ThreadPoolExecutor(3) as ex:
    res = list(ex.map(one, rels))
moved = [r for r in res if r[1] is not None]
print(f'cases={len(rels)} moved={len(moved)}')
for r in moved:
    print(f'{r[0]}\t{r[1][0]}:{r[1][1]}\t->\t{r[2][0]}:{r[2][1]}\t{r[3]}')
