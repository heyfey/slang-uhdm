#!/usr/bin/env python3
# (r11u190: copied from r11u185verify/drivers, paths renamed; the landings under test are passes 180 and 181.)
# (r11u185 (from r11u182verify): copied from r11u177verify, the landings renamed 168 -> 180, 169 -> 181.)
"""bytecancel.py <L> <A> <off180> <off181>: the byte-level composition census over every probe and corpus database
of four sweeps (fenced corpus paths skipped unread by word boundary; fail-closed on $FENCED).  Per database:
  L==A but a single-landing-off sweep differs -> CANCEL candidate (two laws cancelling each other's bytes);
  L!=A -> attributed to the landing(s) whose single-off sweep differs from L (OWN180 / OWN181 / BOTH / NEITHER).
NEITHER = only both-off moves it (a pair needing both landings)."""
import os, re, sys, glob, hashlib, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('bytecancel.py: source drivers/env.sh first')
L, A, O8, O9 = sys.argv[1:5]
def fenced(p): return any(re.search(rf'\b{re.escape(f)}\b', p) for f in F)
def md5(p):
    try: return hashlib.md5(open(p, 'rb').read()).hexdigest()
    except FileNotFoundError: return None
rels = [os.path.relpath(p, L) for p in glob.glob(f'{L}/probe/*.uhdm')]
for c in ('surelog', 'uhdm2rtlil'):
    rels += [os.path.relpath(p, L) for p in glob.glob(f'{L}/{c}/*/*/slang.uhdm') if not fenced(os.path.relpath(p, L))]
tally = collections.Counter(); ex = collections.defaultdict(list)
for r in rels:
    h = [md5(f'{w}/{r}') for w in (L, A, O8, O9)]
    if h[0] == h[1]:
        if h[2] != h[0] or h[3] != h[0]: tally['CANCEL'] += 1; ex['CANCEL'].append(r)
        else: tally['SAME'] += 1
        continue
    d8, d9 = h[2] != h[0], h[3] != h[0]
    t = "BOTH" if d8 and d9 else "OWN180" if d8 else "OWN181" if d9 else "NEITHER"
    tally[t] += 1; ex[t].append(r)
print('databases', len(rels), dict(sorted(tally.items())))
for t in ('CANCEL', 'BOTH', 'NEITHER'):
    for r in ex[t]: print(' ', t, r)
for t in ("OWN180", "OWN181"):
    corp = sorted(set(re.sub(r'-[0-9a-f]+/slang.uhdm$', '', r) for r in ex[t] if not r.startswith('probe/')))
    print(f'  {t}: probe {sum(1 for r in ex[t] if r.startswith("probe/"))}, corpus {len(corp)}: ' + ' '.join(corp))
