#!/usr/bin/env python3
# (r11u229: copied from r11u226verify/drivers; the landings under test are passes 224, 225 and r11u226.)
# (r11u217: generalised from r11u213verify/drivers/compose.py to any number of landings: passes 209, 210 and 212.)
"""compose.py <L> <A> <label>=<off wd>...: the composition census over the gate csvs (probe, surelog, uhdm2rtlil) of
the sweeps: L = HEAD (every law on), A = every landing under test off, and one landing off at a time (r11u217:
209 = R11U209_OFF R11V209_OFF; 210 = R11U210_OFF; 212 = R11U212_OFF R11V212_OFF).  Per row strict-equal
(CMP_EQUAL / EQUAL) in L but not in A: the landing whose single-off sweep loses it (OWN<n>: exactly one; SHARED:
no single-off loses it; JOINT<n+m>: several single-offs lose it (it needs them all)).  Also rows whose strict verdict
changed L vs A without a status change (CHANGE), attributed the same way.  CANCEL: a row whose (status, strict) is
the same in L and A but differs in a single-off sweep (laws cancelling each other's error).  Rows of the fenced
tests are skipped unread (fail-closed on $FENCED)."""
import csv, os, re, sys, collections
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('compose.py: source drivers/env.sh first')
L, A = sys.argv[1:3]
OFF = dict(a.split('=', 1) for a in sys.argv[3:])
NS = list(OFF)
def fenced(n): return any(re.search(rf'\b{re.escape(f)}\b', n) for f in FENCED)
def load(wd, st):
    p = f'{wd}/{st}.csv'
    if not os.path.exists(p): return None
    if st == 'probe': return {r['case']: (r['status'], r['strict']) for r in csv.DictReader(open(p))}
    return {(r['name'], r['mode']): (r['status'], r['strict']) for r in csv.DictReader(open(p)) if not fenced(r['name'])}
EQ = ('CMP_EQUAL', 'EQUAL')
def nm(k): return k if isinstance(k, str) else f'{k[0]}/{k[1][0]}'
def tagof(ns): return f'OWN{ns[0]}' if len(ns) == 1 else 'SHARED' if not ns else 'JOINT' + '+'.join(ns)
for st in ('probe', 'surelog', 'uhdm2rtlil'):
    l, a = load(L, st), load(A, st); offs = {n: load(w, st) for n, w in OFF.items()}
    if not (l and a and all(offs.values())): print(f'== {st}: missing csv'); continue
    own = collections.defaultdict(list); tally = collections.Counter(); cancel = []; chg = collections.defaultdict(list)
    for k, v in l.items():
        va = a.get(k)
        if v[0] in EQ and (va is None or va[0] not in EQ):
            lost = [n for n in NS if offs[n].get(k, ('?',))[0] not in EQ]
            t = tagof(lost); tally[t] += 1; own[t].append(k)
        elif va is not None and va != v:
            moved = [n for n in NS if offs[n].get(k) != v]
            chg[tagof(moved)].append((k, va, v, {n: offs[n].get(k) for n in moved}))
        if va == v:
            for n in NS:
                if offs[n].get(k) != v: cancel.append((k, n, v, offs[n].get(k)))
    print(f'== {st}: rows {len(l)}; conversions L vs A = {sum(tally.values())}: ' + ' '.join(f'{t}={c}' for t, c in sorted(tally.items())))
    for t in sorted(own): print(f'  CONV {t}: ' + ', '.join(nm(k) for k in sorted(own[t])))
    print(f'  CHANGE (L vs A, not a conversion): ' + ' '.join(f'{t}={len(c)}' for t, c in sorted(chg.items())))
    for t in sorted(chg):
        for k, va, v, om in sorted(chg[t]): print(f'    {t} {nm(k)}: A={va[1]} L={v[1]} ' + ' '.join(f'off{n}={x[1] if x else None}' for n, x in om.items()))
    print(f'  CANCEL (same in L and A, different with one landing off): {len(cancel)}')
    for k, n, v, vo in cancel: print(f'    {nm(k)} off{n}: L/A={v} off={vo}')
