#!/usr/bin/env python3
"""bytesame.py <wdA> <wdB>: every probe and corpus database of two sweeps compared byte for byte (fenced corpus paths
skipped unread by word boundary; fail-closed on $FENCED); prints the totals, the differing paths, and whether the
three gate csvs are identical."""
import os, re, sys, glob, hashlib, filecmp
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('bytesame.py: source drivers/env.sh first')
A, B = sys.argv[1:3]
def fenced(p): return any(re.search(rf'\b{re.escape(f)}\b', p) for f in F)
def md5(p):
    try: return hashlib.md5(open(p, 'rb').read()).hexdigest()
    except FileNotFoundError: return None
rels = [os.path.relpath(p, A) for p in glob.glob(f'{A}/probe/*.uhdm')]
for c in ('surelog', 'uhdm2rtlil'):
    rels += [os.path.relpath(p, A) for p in glob.glob(f'{A}/{c}/*/*/slang.uhdm') if not fenced(os.path.relpath(p, A))]
diff = [r for r in rels if md5(f'{A}/{r}') != md5(f'{B}/{r}')]
print(f'databases {len(rels)} (fenced skipped) differ {len(diff)}')
for r in diff: print('  DIFF', r)
for c in ('probe', 'surelog', 'uhdm2rtlil'):
    a, b = f'{A}/{c}.csv', f'{B}/{c}.csv'
    if os.path.exists(a) and os.path.exists(b):
        print(f'  csv {c}: {"identical" if filecmp.cmp(a, b, shallow=False) else "DIFFER"}')
