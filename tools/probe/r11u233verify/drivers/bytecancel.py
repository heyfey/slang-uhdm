#!/usr/bin/env python3
# (r11u233: copied from r11u229verify/drivers; originally copied from r11u226verify/drivers; the landings under test are passes 224, 225 and r11u226.)
# (r11u217: generalised from r11u213verify/drivers/bytecancel.py to any number of landings: passes 209, 210, 212.)
"""bytecancel.py <L> <A> <label>=<off wd>...: the byte-level composition census over every probe and corpus database
and every downstream slang-lane database of the sweeps (fenced corpus paths skipped unread by word boundary;
fail-closed on $FENCED).  Per database:
  L==A but a single-landing-off sweep differs -> CANCEL candidate (laws cancelling each other's bytes);
  L!=A -> attributed to the landing(s) whose single-off sweep differs from L (OWN<n> / JOINT / NEITHER).
NEITHER = only the all-off state moves it."""
import os, re, sys, glob, hashlib, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('bytecancel.py: source drivers/env.sh first')
L, A = sys.argv[1:3]
OFF = dict(a.split('=', 1) for a in sys.argv[3:]); NS = list(OFF)
def fenced(p): return any(re.search(rf'\b{re.escape(f)}\b', p) for f in F)
def md5(p):
    try: return hashlib.md5(open(p, 'rb').read()).hexdigest()
    except FileNotFoundError: return None
rels = [os.path.relpath(p, L) for p in glob.glob(f'{L}/probe/*.uhdm')]
for c in ('surelog', 'uhdm2rtlil'):
    rels += [os.path.relpath(p, L) for p in glob.glob(f'{L}/{c}/*/*/slang.uhdm') if not fenced(os.path.relpath(p, L))]
rels += [os.path.relpath(p, L) for p in glob.glob(f'{L}/downstream/*/slang.uhdm') if not fenced(os.path.relpath(p, L))]
tally = collections.Counter(); ex = collections.defaultdict(list)
for r in rels:
    hl, ha = md5(f'{L}/{r}'), md5(f'{A}/{r}')
    ho = {n: md5(f'{OFF[n]}/{r}') for n in NS}
    if hl == ha:
        if any(h != hl for h in ho.values()): tally['CANCEL'] += 1; ex['CANCEL'].append((r, [n for n in NS if ho[n] != hl]))
        else: tally['SAME'] += 1
        continue
    d = [n for n in NS if ho[n] != hl]
    t = f'OWN{d[0]}' if len(d) == 1 else 'JOINT' + '+'.join(d) if d else 'NEITHER'
    tally[t] += 1; ex[t].append((r, d))
print('databases', len(rels), dict(sorted(tally.items())))
for t in sorted(ex):
    if t.startswith('OWN'): continue
    for r, d in ex[t]: print(' ', t, r, d)
for t in sorted(ex):
    if not t.startswith('OWN'): continue
    corp = sorted(set(re.sub(r'-[0-9a-f]+/slang.uhdm$', '', r) for r, _ in ex[t] if r.startswith(('surelog', 'uhdm2rtlil'))))
    lanes = sorted(set(r.split('/')[1] for r, _ in ex[t] if r.startswith('downstream/')))
    print(f'  {t}: probe {sum(1 for r, _ in ex[t] if r.startswith("probe/"))}, corpus {len(corp)}: ' + ' '.join(corp) + f' | lanes {len(lanes)}: ' + ' '.join(lanes))
