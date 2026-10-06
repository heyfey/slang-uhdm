#!/usr/bin/env python3
# v11u269 probemovers.py <probe wdA> <probe wdB>: the probe databases whose bytes differ between two check_probe
# runs made from the SAME checkout (the case path is embedded); asserts identical path sets. Probe cases hold no
# fenced test; every path is still checked against $FENCED (fail closed).
import os, re, sys, hashlib
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('probemovers.py: FENCED unset')
fz = re.compile(r'(?<![A-Za-z0-9_])(?:%s)(?![A-Za-z0-9_])' % '|'.join(map(re.escape, F)))
def files(r):
    return {f: os.path.join(r, f) for f in os.listdir(r) if f.endswith('.uhdm') and not fz.search(f)}
a, b = files(sys.argv[1]), files(sys.argv[2])
assert set(a) == set(b), 'path sets differ'
h = lambda p: hashlib.md5(open(p, 'rb').read()).hexdigest()
mv = [k for k in sorted(a) if h(a[k]) != h(b[k])]
print(f'probe databases={len(a)} movers={len(mv)}')
for k in mv: print('MOVER', k)
