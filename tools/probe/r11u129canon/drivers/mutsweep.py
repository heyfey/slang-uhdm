#!/usr/bin/env python3
"""Mutation sweep (question 1): pick N corpus row-modes STRICT_EQUAL under mode 3 whose walk has at most
MAXREC records a side and at least one full-name-carrying object inside a canonicalised subtree, spread
evenly over the sorted list, and run mutaudit on each (side, K objects). Output TSV = mutaudit lines.
usage: mutsweep.py <final_corpus.csv> <pairs.tsv> <out.tsv> <N> <K> <side> [jobs] [maxrec]"""
import concurrent.futures, csv, hashlib, subprocess, sys
src, pairs, out, N, K, side = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4]), sys.argv[5], sys.argv[6]
jobs = int(sys.argv[7]) if len(sys.argv) > 7 else 3
maxrec = int(sys.argv[8]) if len(sys.argv) > 8 else 60000
MUT = '/tmp/r11u129_bin/mutaudit_g'
COL = __import__('os').environ.get('COL', 'm3')  # the mode-3 column of the run_modes csv
P = {}
for l in open(pairs):
    f = l.rstrip('\n').split('\t'); P[(f[0], f[2], f[1])] = (f[3], f[4])
rows = sorted((r['corpus'], r['test'], r['mode']) for r in csv.DictReader(open(src))
              if r[COL] == 'equal' and r[COL + '_n'] and int(r[COL + '_n']) <= maxrec)
def run(k):
    g, o = P[k]
    r = subprocess.run([MUT, g, o, side, K, '/'.join(k)], capture_output=True, text=True, timeout=3600)
    return k, r.stdout, r.stderr
# a deterministic spread: rows ordered by the md5 of their key; mutaudit prints nothing for a row with no
# candidate, and the first N rows (in that order) that have one are kept
pick = sorted(rows, key=lambda k: hashlib.md5('/'.join(k).encode()).hexdigest())
got = 0
with open(out, 'w') as fo, concurrent.futures.ThreadPoolExecutor(jobs) as ex:
    for k, so, se in ex.map(run, pick):
        if so.strip() and got < N:
            fo.write(so); got += 1
        sys.stderr.write(se)
print(f'rows eligible {len(rows)} tried {len(pick)} with candidates written {got}')
