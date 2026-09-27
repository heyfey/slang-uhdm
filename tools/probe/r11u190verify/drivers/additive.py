#!/usr/bin/env python3
# (r11u190: copied from r11u185verify/drivers, paths renamed; the landings under test are passes 180 and 181.)
"""additive.py <H> <A> <Q> <W>: do passes 176 + 178 compose additively with passes 171, 174, 181 and the refinements?
(r11u185: copied from r11u182verify.)  H = HEAD (every law on), A = 176 + 178 off (R11U175_OFF R11U176_OFF R11U178_OFF
R11V178_OFF), Q = 171/172/174/181 and the refinements 171v/174v/177v/181v/182v off (R11U172_OFF R11U171_OFF R11V171_OFF
R11U174_OFF R11V174_MOPPKG_OFF R11U181_OFF R11V181_OFF R11V177_OFF R11V182_OFF), W = all of them off.  The 176/178 delta is
read twice: on HEAD's base (A -> H) and on the base without the others (W -> Q).  Per gate csv row: CONVERSION (enters CMP_EQUAL / EQUAL) or CHANGE (another (status, strict)
move) in each delta; the two deltas must name the same rows with the same (from, to) pairs.  Byte level: the set of
databases the 171/174 switches move on each base.  Fenced corpus rows are skipped unread (fail-closed on $FENCED)."""
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
    print(f'== {st}: 176/178 delta on HEAD base {len(d1)} rows ({len(c1)} conversions); on the others-off base {len(d2)} rows ({len(c2)} conversions); identical (from,to) on both: {len(same)}')
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
print(f'== bytes: databases {len(rels)}; 176/178 movers on HEAD base {len(m1)}, on the off base {len(m2)}, both {len(m1 & m2)}')
for r in sorted(m1 ^ m2): print('   ', 'HEAD-base-only' if r in m1 else 'off-base-only', r)
