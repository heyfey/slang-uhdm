#!/usr/bin/env python3
# caseaway.py <case-store-dir> <offtag> <ontag>: away census on one case-view's strictcmp record dumps (case.sh keeps
# <tag>.a.rec = golden, <tag>.b.rec = ours). Keys: chain (ancestor (type,name) path + the record without depth) and
# flat (record without depth), as multisets. away = golden-agreeing records OFF had and ON lost; toward = reverse.
# Reads only the case store (cases under this repro dir; no corpus source or database is opened).
import sys, os, collections
d, off, on = sys.argv[1:4]
def load(f, chain):
    c = collections.Counter(); st = []
    if not os.path.exists(f): return c
    for l in open(f):
        x = l.rstrip('\n').split('\t'); dep = int(x[0]); st = st[:dep] + [x[1] + ':' + x[2]]
        c[(('/'.join(st[:-1]),) if chain else ()) + tuple(x[1:])] += 1
    return c
for chain in (1, 0):
    G = load(f'{d}/{on}.a.rec', chain); P = load(f'{d}/{off}.b.rec', chain); L = load(f'{d}/{on}.b.rec', chain)
    lost = (G & P) - L; gain = (G & L) - P
    print(('chain' if chain else 'flat'), f'away={sum(lost.values())} toward={sum(gain.values())} dist {sum((P-G).values())} -> {sum((L-G).values())}')
    if len(sys.argv) > 4:
        for k, v in list(lost.items())[:20]: print('  LOST', v, '|'.join(k))
