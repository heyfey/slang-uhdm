#!/usr/bin/env python3
"""additive.py <H> <A> <Q> <W>: do passes 168 + 169 compose additively with passes 164, 167 and r11u173's refinement?
H = HEAD (every law on), A = 168 + 169 off, Q = 164 + 167 + r11u173 off (R11U161_OFF R11U164_OFF R11U167_OFF
R11V173_OFF), W = all of them off.  The 168/169 delta is read twice: on HEAD's base (A -> H) and on the base without
164/167/173 (W -> Q).  Per gate csv row: CONVERSION (enters CMP_EQUAL / EQUAL) or CHANGE (another (status, strict)
move) in each delta; the two deltas must name the same rows with the same (from, to) pairs.  Byte level: the set of
databases the 168/169 switches move on each base.  Fenced corpus rows are skipped unread (fail-closed on $FENCED)."""
import csv, os, re, sys, glob, hashlib
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('additive.py: source drivers/env.sh first')
H, A, Q, W = sys.argv[1:5]
def fenced(n): return any(re.search(rf'\b{re.escape(f)}\b', n) for f in F)
def load(wd, st):
    p = f'{wd}/{st}.csv'
    if st == 'probe': return {r['case']: (r['status'], r['strict']) for r in csv.DictReader(open(p))}
    return {(r['name'], r['mode']): (r['status'], r['strict']) for r in csv.DictReader(open(p)) if not fenced(r['name'])}
EQ = ('CMP_EQUAL', 'EQUAL')
def nm(k): return k if isinstance(k, str) else f'{k[0]}/{k[1][0]}'
for st in ('probe', 'surelog', 'uhdm2rtlil'):
    h, a, q, w = (load(x, st) for x in (H, A, Q, W))
    d1 = {k: (a.get(k), h[k]) for k in h if a.get(k) != h[k]}
    d2 = {k: (w.get(k), q[k]) for k in q if w.get(k) != q.get(k)}
    c1 = {k for k, (x, y) in d1.items() if y[0] in EQ and (x is None or x[0] not in EQ)}
    c2 = {k for k, (x, y) in d2.items() if y[0] in EQ and (x is None or x[0] not in EQ)}
    same = [k for k in set(d1) & set(d2) if d1[k] == d2[k]]
    print(f'== {st}: 168/169 delta on HEAD base {len(d1)} rows ({len(c1)} conversions); on the 164/167/173-off base {len(d2)} rows ({len(c2)} conversions); identical (from,to) on both: {len(same)}')
    for k in sorted(set(d1) ^ set(d2), key=str): print('   ONLY-ONE-BASE', nm(k), 'HEAD-base', d1.get(k), '| off-base', d2.get(k))
    for k in sorted((set(d1) & set(d2)) - set(same), key=str): print('   DIFFERENT-MOVE', nm(k), 'HEAD-base', d1[k], '| off-base', d2[k])
def md5(p):
    try: return hashlib.md5(open(p, 'rb').read()).hexdigest()
    except FileNotFoundError: return None
rels = [os.path.relpath(p, H) for p in glob.glob(f'{H}/probe/*.uhdm')]
for c in ('surelog', 'uhdm2rtlil'):
    rels += [os.path.relpath(p, H) for p in glob.glob(f'{H}/{c}/*/*/slang.uhdm') if not fenced(os.path.relpath(p, H))]
m1 = {r for r in rels if md5(f'{H}/{r}') != md5(f'{A}/{r}')}
m2 = {r for r in rels if md5(f'{Q}/{r}') != md5(f'{W}/{r}')}
print(f'== bytes: databases {len(rels)}; 168/169 movers on HEAD base {len(m1)}, on the off base {len(m2)}, both {len(m1 & m2)}')
for r in sorted(m1 ^ m2): print('   ', 'HEAD-base-only' if r in m1 else 'off-base-only', r)
