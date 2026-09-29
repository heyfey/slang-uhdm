#!/usr/bin/env python3
"""r11u233: predict233.py <trace dir> <census workdir>: the frozen mover prediction of the fix: every database whose
slang-uhdm process fired a refinement of r11u233 (<pid>.233 trace files, first line `OUT <-o path>`), named by its
path relative to the census workdir, with the refinement names that fired.  A database whose name holds a fenced test
is not named (it cannot be one: the refinements are not fenced-test shapes; the census counts them apart)."""
import os, re, sys, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('predict233.py: source drivers/env.sh first')
T, W = sys.argv[1:3]
out = collections.defaultdict(collections.Counter); fenced = 0; files = 0
for fn in sorted(os.listdir(T)):
    if not fn.endswith('.233'): continue
    files += 1
    L = open(os.path.join(T, fn), errors='replace').read().splitlines()
    o = L[0][4:] if L and L[0].startswith('OUT ') else '?'
    if any(re.search(rf'\b{re.escape(n)}\b', o) for n in F): fenced += 1; continue
    o = o.replace(W.rstrip('/') + '/', '')
    for l in L[1:]:
        if l.strip(): out[o][l.split()[0]] += 1
print(f'# trace files {files}; fenced-named outputs {fenced}; databases {len(out)}')
for o in sorted(out): print(o, ' '.join(f'{k}:{v}' for k, v in sorted(out[o].items())))
