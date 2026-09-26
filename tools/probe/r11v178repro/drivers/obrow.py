#!/usr/bin/env python3
# obrow.py <golden.uhdm> <a.uhdm> <b.uhdm>: order-blind record distance of a and b to golden (strictcmp records,
# depth dropped), plus the records b has that a lacks and vice versa (not in golden).  Fenced names refused.
import os, re, sys, subprocess, collections
FEN = os.environ.get('FENCED', '').split(); assert len(FEN) == 4, 'FENCED'
fre = re.compile(r'\b(' + '|'.join(FEN) + r')\b')
g, a, b = sys.argv[1:4]
assert not any(fre.search(x) for x in (a, b)), 'fenced'
X = '/tmp/v11u178_bin/uhdm-strictcmp'; T = '/tmp/v11u178_obr'; os.makedirs(T, exist_ok=True)
def recs(o, tag):
    subprocess.run([X, '--max', '0', '--dump-a', f'{T}/g', '--dump-b', f'{T}/{tag}', g, o], capture_output=True)
    return (collections.Counter('\t'.join(l.rstrip('\n').split('\t')[1:14]) for l in open(f'{T}/g', errors='replace')),
            collections.Counter('\t'.join(l.rstrip('\n').split('\t')[1:14]) for l in open(f'{T}/{tag}', errors='replace')))
G, A = recs(a, 'a'); _, B = recs(b, 'b')
da = sum((A - G).values()) + sum((G - A).values()); db = sum((B - G).values()) + sum((G - B).values())
print('dist a', da, 'b', db, 'TOWARD' if db < da else 'AWAY' if db > da else 'SAME')
for k, v in list(((B - G) - (A - G)).items())[:int(os.environ.get('N', '12'))]: print('  b-only-wrong', v, k)
for k, v in list(((A - G) - (B - G)).items())[:int(os.environ.get('N', '12'))]: print('  a-only-wrong', v, k)
