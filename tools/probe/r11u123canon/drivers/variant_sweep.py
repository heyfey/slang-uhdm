#!/usr/bin/env python3
"""Verdict of one comparator binary (+ env switches) on every pair: the root-set
experiments of question 3 and the fixed binary's re-measure.
usage: variant_sweep.py <pairs.tsv> <out.csv> <binary> [ENV=1 ...]"""
import concurrent.futures, csv, os, subprocess, sys, time
pairs, out, SC = sys.argv[1], sys.argv[2], sys.argv[3]
env = dict(os.environ)
for kv in sys.argv[4:]:
    k, v = kv.split('=', 1)
    env[k] = v


def verdict(rc, stdout):
    if rc == 0:
        return 'equal', stdout.strip().split()[-2] if 'STRICT_EQUAL' in stdout else ''
    if rc == 1:
        return 'differ:stage1', ''
    if 'canon overflow' in stdout:
        return 'overflow', ''
    field = n = ''
    for line in stdout.splitlines():
        if line.startswith('STRICT_NOTEQUAL '):
            field = line.split(' ', 1)[1].strip()
        if 'objects_differing=' in line:
            n = line.split('objects_differing=')[1].split()[0]
    return (f'differ:{field}({n})' if n else f'differ:{field or "?"}:rc{rc}'), ''


def one(f):
    t0 = time.time()
    try:
        r = subprocess.run([SC, '--max', '0', f[5], f[6]], capture_output=True, text=True, env=env, timeout=600)
        v, n = verdict(r.returncode, r.stdout)
    except subprocess.TimeoutExpired:
        v, n = 'timeout', ''
    return [f[0], f[2], f[1], v, n, f'{time.time() - t0:.2f}']


rows = [l.rstrip('\n').split('\t') for l in open(pairs)]
with open(out, 'w', newline='') as fo, concurrent.futures.ThreadPoolExecutor(3) as pool:
    w = csv.writer(fo)
    w.writerow(['corpus', 'test', 'mode', 'verdict', 'records', 'secs'])
    for res in pool.map(one, rows):
        w.writerow(res)
print('DONE', len(rows))
