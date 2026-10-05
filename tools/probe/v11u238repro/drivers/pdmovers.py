#!/usr/bin/env python3
# (v11u238) pdmovers.py <wdA> <wdB>: probe and downstream-lane databases that differ between two gate sweeps, with each
# sweep's own workdir string replaced by a fixed one first (the probe databases embed it; the names must have the same
# length). Downstream paths naming a fenced test are skipped unread (fail-closed on $FENCED; the uhdm2rtlil corpus
# holds none of them, checked anyway). Prints the count and the movers; a positive control compares two lanes.
import os, re, sys, glob
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('pdmovers.py: source drivers/env.sh first')
A, B = [os.path.abspath(x) for x in sys.argv[1:3]]
assert len(A) == len(B), 'workdir names must have the same length'
def fenced(p): return any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', p) for f in F)
def rd(p, w): return open(p, 'rb').read().replace(w.encode(), b'/W' + b'_' * (len(w) - 2))
for kind, pat in (('probe', 'probe/*.uhdm'), ('downstream', 'downstream/*/slang.uhdm')):
    fa = sorted(os.path.relpath(p, A) for p in glob.glob(f'{A}/{pat}') if not fenced(p))
    mv = [r for r in fa if os.path.exists(f'{B}/{r}') and rd(f'{A}/{r}', A) != rd(f'{B}/{r}', B)]
    miss = [r for r in fa if not os.path.exists(f'{B}/{r}')]
    print(f'{kind}: {len(fa)} databases, {len(mv)} differ, {len(miss)} only in A')
    for r in mv: print('  MOVER', r)
    if kind == 'downstream' and len(fa) > 1:
        print('  positive control', fa[0], 'vs', fa[1], 'differ:', rd(f'{A}/{fa[0]}', A) != rd(f'{B}/{fa[1]}', B))
