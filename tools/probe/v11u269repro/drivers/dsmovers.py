#!/usr/bin/env python3
# v11u269 dsmovers.py <downstream wdA> <downstream wdB>: the slang-lane databases (<test>/slang.uhdm) whose bytes
# differ between two downstream sweeps; asserts identical path sets; a test naming a fenced test is skipped unread
# (fail-closed on $FENCED).
import os, re, sys, hashlib
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('dsmovers.py: FENCED unset')
fz = re.compile(r'(?<![A-Za-z0-9_])(?:%s)(?![A-Za-z0-9_])' % '|'.join(map(re.escape, F)))
def files(r):
    out = {}; sk = 0
    for t in sorted(os.listdir(r)):
        if fz.search(t): sk += 1; continue
        p = os.path.join(r, t, 'slang.uhdm')
        if os.path.exists(p): out[t] = p
    return out, sk
(a, sa), (b, sb) = files(sys.argv[1]), files(sys.argv[2])
assert set(a) == set(b), 'path sets differ'
h = lambda p: hashlib.md5(open(p, 'rb').read()).hexdigest()
mv = [k for k in a if h(a[k]) != h(b[k])]
print(f'slang-lane databases={len(a)} fenced_skipped={sa} movers={len(mv)}')
for k in mv: print('MOVER', k)
