#!/usr/bin/env python3
"""share175.py <H> <F> <E>: each ground's share of R11U175 on the HEAD base.  F = R11U175_FSPAN_OFF (the one TaskFuncEmit
law, pass 176's ground), E = R11U175_MULT_OFF R11U175_FULLNAME_OFF R11U175_ESPAN_OFF (the three expression laws, pass
178's ground).  Per gate csv: rows whose (status, strict) differs from H, the conversions each drop loses, and the
byte movers of each drop (probe and corpus databases; fenced corpus rows skipped unread, fail-closed on $FENCED)."""
import csv, os, re, sys, glob, hashlib, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('share175.py: source drivers/env.sh first')
H, SF, SE = sys.argv[1:4]
fen = lambda n: any(re.search(rf'\b{re.escape(f)}\b', n) for f in F)
def load(wd, st):
    p = f'{wd}/{st}.csv'
    if st == 'probe': return {r['case']: (r['status'], r['strict']) for r in csv.DictReader(open(p))}
    return {(r['name'], r['mode']): (r['status'], r['strict']) for r in csv.DictReader(open(p)) if not fen(r['name'])}
EQ = ('CMP_EQUAL', 'EQUAL')
for st in ('probe', 'surelog', 'uhdm2rtlil'):
    h = load(H, st)
    for tag, w in (('FSPAN (176 ground)', SF), ('MULT+FULLNAME+ESPAN (178 ground)', SE)):
        o = load(w, st)
        d = [k for k in h if o.get(k) != h[k]]
        lost = [k for k in d if h[k][0] in EQ]
        print(f'== {st} {tag}: rows moved {len(d)}, conversions owned {len(lost)}')
        for k in sorted(d, key=str)[:60]:
            if st != 'probe' or k in lost: print(f'    {k}: off={o.get(k)} H={h[k]}')
md5 = lambda p: hashlib.md5(open(p, 'rb').read()).hexdigest() if os.path.exists(p) else None
rels = [os.path.relpath(p, H) for p in glob.glob(f'{H}/probe/*.uhdm')]
for c in ('surelog', 'uhdm2rtlil'):
    rels += [os.path.relpath(p, H) for p in glob.glob(f'{H}/{c}/*/*/slang.uhdm') if not fen(os.path.relpath(p, H))]
mf = {r for r in rels if md5(f'{H}/{r}') != md5(f'{SF}/{r}')}; me = {r for r in rels if md5(f'{H}/{r}') != md5(f'{SE}/{r}')}
cor = lambda s: sorted(set(re.sub(r'-[0-9a-f]+/slang.uhdm$', '', r) for r in s if not r.startswith('probe/')))
print(f'== bytes: FSPAN movers {len(mf)} (probe {sum(1 for r in mf if r.startswith("probe/"))}; corpus {cor(mf)}), '
      f'expression-three movers {len(me)} (probe {sum(1 for r in me if r.startswith("probe/"))}; corpus {cor(me)}), both {len(mf & me)}')
