#!/usr/bin/env python3
# consts.py <a.txt> <b.txt>: the constant records (strictcmp --dump-a/--dump-b) side by side by position:
# line:col-endline:endcol decompile size value consttype, golden (A) | ours (B); '=' when equal.
import sys, collections
def load(fn):
    d = collections.OrderedDict()
    for l in open(fn):
        f = l.rstrip('\n').split('\t')
        if len(f) > 13 and f[1] == 'constant':
            k = f'{f[6]}:{f[7]}-{f[8]}:{f[9]}'
            d.setdefault(k, set()).add(f'{f[10]}|{f[11]}|{f[12]}|{f[13]}')
    return d
A, B = load(sys.argv[1]), load(sys.argv[2])
for k in sorted(set(A) | set(B), key=lambda s: [int(x) for x in s.replace('-', ':').split(':')]):
    a, b = sorted(A.get(k, [])), sorted(B.get(k, []))
    print(f'{k:16} ' + ('= ' + ' '.join(a) if a == b else 'A ' + ' '.join(a) + '  |  B ' + ' '.join(b)))
