#!/usr/bin/env python3
"""Run the strict comparator raw (--no-canon) and canonical on every pair from
pairs.py, recording verdict, exit code, record counts per side and wall time.
Record dumps are kept (under DUMPS/<corpus>_<mode>_<test>/{rawA,rawB,canA,canB})
for rows the identity check or the residue classification needs: raw not equal
and canon equal, or canon first field depth/count/type.

usage: run_all.py <pairs.tsv> <out.csv> <dumps dir> [jobs] [strictcmp]"""
import concurrent.futures, csv, os, subprocess, sys, time

pairs, out, dumps = sys.argv[1], sys.argv[2], sys.argv[3]
jobs = int(sys.argv[4]) if len(sys.argv) > 4 else 3
SC = sys.argv[5] if len(sys.argv) > 5 else '/tmp/r11u123_bin/uhdm-strictcmp'


def verdict(rc, stdout):
    if rc == 0:
        return 'equal'
    if rc == 1:
        return 'differ:stage1'
    field = n = ''
    for line in stdout.splitlines():
        if line.startswith('STRICT_NOTEQUAL '):
            field = line.split(' ', 1)[1].strip()
        if 'objects_differing=' in line:
            n = line.split('objects_differing=')[1].split()[0]
    if 'canon overflow' in stdout:
        return 'overflow'
    return f'differ:{field}({n})' if n else f'differ:{field or "?"}:rc{rc}'


def lines(p):
    if not os.path.exists(p):
        return -1
    with open(p, 'rb') as f:
        return sum(1 for _ in f)


def one(row):
    corpus, mode, test, old, new, g, o = row[:7]
    d = os.path.join(dumps, f'{corpus}_{mode}_{test}')
    os.makedirs(d, exist_ok=True)
    res = {'corpus': corpus, 'mode': mode, 'test': test, 'old': old, 'new': new}
    for tag, extra in (('raw', ['--no-canon']), ('can', [])):
        a, b = os.path.join(d, tag + 'A'), os.path.join(d, tag + 'B')
        for p in (a, b):
            if os.path.exists(p):
                os.remove(p)
        t0 = time.time()
        r = subprocess.run([SC, '--max', '5'] + extra + ['--dump-a', a, '--dump-b', b, g, o],
                           capture_output=True, text=True, timeout=900)
        res[tag + '_s'] = f'{time.time() - t0:.2f}'
        res[tag + '_rc'] = r.returncode
        res[tag + '_v'] = verdict(r.returncode, r.stdout)
        res[tag + '_nA'] = lines(a)
        res[tag + '_nB'] = lines(b)
        with open(os.path.join(d, tag + '.out'), 'w') as f:
            f.write(r.stdout + r.stderr)
    keep = (res['raw_v'] != 'equal' and res['can_v'] == 'equal') or \
        res['can_v'].split('(')[0] in ('differ:depth', 'differ:count', 'differ:type')
    if not keep:
        for tag in ('rawA', 'rawB', 'canA', 'canB'):
            p = os.path.join(d, tag)
            if os.path.exists(p):
                os.remove(p)
    return res


rows = [l.rstrip('\n').split('\t') for l in open(pairs)]
cols = ['corpus', 'mode', 'test', 'old', 'new', 'raw_v', 'can_v', 'raw_rc', 'can_rc', 'raw_nA',
        'raw_nB', 'can_nA', 'can_nB', 'raw_s', 'can_s']
with open(out, 'w', newline='') as f, concurrent.futures.ThreadPoolExecutor(jobs) as pool:
    w = csv.DictWriter(f, cols)
    w.writeheader()
    for res in pool.map(one, rows):
        w.writerow(res)
        f.flush()
print('DONE', len(rows))
