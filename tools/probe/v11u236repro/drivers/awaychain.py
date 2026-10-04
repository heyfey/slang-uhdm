#!/usr/bin/env python3
# v11u236: chain-keyed AWAY census from three strict record dumps (uhdm-strictcmp --dump-a/--dump-b): golden, pristine,
# law. A record's key is itself (depth dropped) plus every ancestor record of the walk (by depth). LOST = in golden
# AND pristine, not in law; TOWARD = in golden AND law, not in pristine. Fail-closed on $FENCED (refuses a path naming
# a fenced test).  usage: awaychain.py <golden.rec> <pristine.rec> <law.rec> [-v]
import sys, os, re, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('awaychain: FENCED not set (source drivers/env.sh)')
for p in sys.argv[1:4]:
    if any(re.search(r'\b%s\b' % re.escape(n), p) for n in F): sys.exit('awaychain: fenced path refused')
def keys(f):
    c = collections.Counter(); st = []
    if not os.path.exists(f): return c
    for l in open(f):
        t = l.rstrip('\n').split('\t')
        try: d = int(t[0])
        except ValueError: continue
        st = st[:d]; st += [None] * (d - len(st)); st.append('\t'.join(t[1:]))
        c['\x1f'.join(x or '' for x in st)] += 1
    return c
G, P, L = (keys(f) for f in sys.argv[1:4])
lost = (G & P) - L; tow = (G & L) - P
print(f'lost={sum(lost.values())} toward={sum(tow.values())}')
if '-v' in sys.argv:
    for k, v in lost.items(): print('  LOST', v, k.split('\x1f')[-1])
    for k, v in tow.items(): print('  TOWARD', v, k.split('\x1f')[-1])
