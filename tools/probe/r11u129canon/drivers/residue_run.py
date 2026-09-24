#!/usr/bin/env python3
"""residue_run.py <g4 csv> <pairs.tsv> <out.tsv> [jobs]: residue (question 3) on every corpus row-mode the
final comparator reads STRICT_NOTEQUAL (stage-1-equal pairs only)."""
import concurrent.futures, csv, subprocess, sys
src, pairs, out = sys.argv[1], sys.argv[2], sys.argv[3]
jobs = int(sys.argv[4]) if len(sys.argv) > 4 else 3
P = {}
for l in open(pairs):
    f = l.rstrip('\n').split('\t'); P[(f[0], f[2], f[1])] = (f[3], f[4])
import os
col = os.environ.get('COL', 'm4')  # the final comparator's column
rows = [(r['corpus'], r['test'], r['mode']) for r in csv.DictReader(open(src)) if r[col].startswith('differ')]
def run(k):
    g, o = P[k]
    r = subprocess.run(['/tmp/r11u129_bin/residue_g', g, o, '/'.join(k)], capture_output=True, text=True, timeout=3600)
    return r.stdout.strip() or ('/'.join(k) + '\terror:' + r.stderr.strip()[:80])
with open(out, 'w') as fo, concurrent.futures.ThreadPoolExecutor(jobs) as ex:
    for line in ex.map(run, rows):
        fo.write(line + '\n'); fo.flush()
print(len(rows), 'rows')
