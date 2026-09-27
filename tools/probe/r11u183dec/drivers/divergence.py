#!/usr/bin/env python3
"""r11u183: where the strict walk diverges (first record whose depth or type differs, index-aligned) for a row's
record dumps (strictcmp_x --dump-a/-b), pristine vs law: a STRICT count that GROWS while the order-blind distance
shrinks is the compared prefix getting longer.   usage: divergence.py <pristine dumps dir> <law dumps dir> <row>..."""
import sys, os
P, L = sys.argv[1:3]
def first(a, b):
    with open(a, errors='replace') as fa, open(b, errors='replace') as fb:
        for i, (x, y) in enumerate(zip(fa, fb)):
            if x.split('\t')[:2] != y.split('\t')[:2]:
                return i
    return None
for row in sys.argv[3:]:
    c, m, t = row.split('/')
    r = []
    for D in (P, L):
        a, b = f'{D}/{c}/{m}/{t}.a', f'{D}/{c}/{m}/{t}.b'
        r.append(first(a, b) if os.path.exists(a) and os.path.exists(b) else 'no-dump')
    print(f'{row}\tpristine walk diverges at record {r[0]}\tlaw at {r[1]}')
