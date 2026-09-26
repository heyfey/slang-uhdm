#!/usr/bin/env python3
"""bytecancel.py <L> <A> <off164> <off167>: the byte-level composition census over every probe and corpus database
of four sweeps (fenced corpus paths skipped unread by word boundary; fail-closed on $FENCED).  Per database:
  L==A but a single-landing-off sweep differs -> CANCEL candidate (two laws cancelling each other's bytes);
  L!=A -> attributed to the landing(s) whose single-off sweep differs from L (OWN164 / OWN167 / BOTH / NEITHER).
NEITHER = only both-off moves it (a pair needing both landings)."""
import os, re, sys, glob, hashlib, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('bytecancel.py: source drivers/env.sh first')
L, A, O4, O7 = sys.argv[1:5]
def fenced(p): return any(re.search(rf'\b{re.escape(f)}\b', p) for f in F)
def md5(p):
    try: return hashlib.md5(open(p, 'rb').read()).hexdigest()
    except FileNotFoundError: return None
rels = [os.path.relpath(p, L) for p in glob.glob(f'{L}/probe/*.uhdm')]
for c in ('surelog', 'uhdm2rtlil'):
    rels += [os.path.relpath(p, L) for p in glob.glob(f'{L}/{c}/*/*/slang.uhdm') if not fenced(os.path.relpath(p, L))]
tally = collections.Counter(); ex = collections.defaultdict(list)
for r in rels:
    h = [md5(f'{w}/{r}') for w in (L, A, O4, O7)]
    if h[0] == h[1]:
        if h[2] != h[0] or h[3] != h[0]: tally['CANCEL'] += 1; ex['CANCEL'].append(r)
        else: tally['SAME'] += 1
        continue
    d4, d7 = h[2] != h[0], h[3] != h[0]
    t = 'BOTH' if d4 and d7 else 'OWN164' if d4 else 'OWN167' if d7 else 'NEITHER'
    tally[t] += 1; ex[t].append(r)
print('databases', len(rels), dict(sorted(tally.items())))
for t in ('CANCEL', 'BOTH', 'NEITHER'):
    for r in ex[t]: print(' ', t, r)
for t in ('OWN164', 'OWN167'):
    corp = sorted(set(re.sub(r'-[0-9a-f]+/slang.uhdm$', '', r) for r in ex[t] if not r.startswith('probe/')))
    print(f'  {t}: probe {sum(1 for r in ex[t] if r.startswith("probe/"))}, corpus {len(corp)}: ' + ' '.join(corp))
