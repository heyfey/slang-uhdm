#!/usr/bin/env python3
# (v11u253) dumpaway.py <golden> <pristine> <law> [v]: an order-blind line-multiset census of uhdm-dump output for
# case-views the strict walk cannot read (stage 1): ids, absolute paths and indentation dropped; LOST = lines golden
# and pristine share that law lacks; GAINED = lines golden and law share that pristine lacks. Fail-closed on $FENCED.
import os, re, sys, subprocess, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('dumpaway.py: FENCED not set')
if any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', p) for f in F for p in sys.argv[1:4]): sys.exit('fenced path refused')
D = os.environ.get('UHDM_DUMP', '')
if not os.access(D, os.X_OK): sys.exit('UHDM_DUMP not executable')
def lines(f):
    out = subprocess.run([D, f], capture_output=True, text=True).stdout
    c = collections.Counter()
    for l in out.splitlines():
        l = re.sub(r'id:\d+', 'id', l); l = re.sub(r'file:\S*/', 'file:', l); l = l.strip(' |\\_')
        if l: c[l] += 1
    return c
G, P, L = (lines(f) for f in sys.argv[1:4])
lost = (G & P) - L; gained = (G & L) - P
print(f'dist {sum((P-G).values())} -> {sum((L-G).values())} lost={sum(lost.values())} gained={sum(gained.values())}')
if len(sys.argv) > 4:
    for k, v in lost.items(): print('  LOST', v, k)
    for k, v in gained.items(): print('  GAIN', v, k)
    for k, v in ((L - G) - (P - G)).items(): print('  NEWAWAY', v, k)
