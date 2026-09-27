#!/usr/bin/env python3
# (r11u190: copied from r11u185verify/drivers, paths renamed; the landings under test are passes 180 and 181.)
"""compose.py <L> <A> <off180> <off181>: the composition census over the gate csvs (probe, surelog, uhdm2rtlil) of
four sweeps: L = HEAD (every law on), A = both landings off (R11U180_OFF R11V180_OFF R11U181_OFF R11V181_OFF), and one landing off
at a time (off180 = R11U180_OFF R11V180_OFF; off181 = R11U181_OFF R11V181_OFF).  (r11u185 (from r11u182verify): copied from r11u177verify, the landings renamed 168 -> 180, 169 -> 181.)
Per row strict-equal (CMP_EQUAL / EQUAL) in L but not in A: the landing whose single-off sweep loses it (OWN n:
exactly one; SHARED: neither single-off loses it (either landing alone keeps it); JOINT: both single-offs lose it
(it needs both)).  Also rows whose strict verdict changed L vs A without a status change (CHANGE), attributed the
same way.  CANCEL: a row whose (status, strict) is the same in L and A but differs in a single-off sweep (a pair of
laws cancelling each other's error).  Rows of the fenced tests are skipped unread (fail-closed on $FENCED)."""
import csv, os, re, sys, collections
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('compose.py: source drivers/env.sh first')
L, A, O8, O9 = sys.argv[1:5]
OFF = {180: O8, 181: O9}
def fenced(n): return any(re.search(rf'\b{re.escape(f)}\b', n) for f in FENCED)
def load(wd, st):
    p = f'{wd}/{st}.csv'
    if not os.path.exists(p): return None
    if st == 'probe': return {r['case']: (r['status'], r['strict']) for r in csv.DictReader(open(p))}
    return {(r['name'], r['mode']): (r['status'], r['strict']) for r in csv.DictReader(open(p)) if not fenced(r['name'])}
EQ = ('CMP_EQUAL', 'EQUAL')
def nm(k): return k if isinstance(k, str) else f'{k[0]}/{k[1][0]}'
for st in ('probe', 'surelog', 'uhdm2rtlil'):
    l, a = load(L, st), load(A, st); offs = {n: load(w, st) for n, w in OFF.items()}
    if not (l and a and all(offs.values())): print(f'== {st}: missing csv'); continue
    own = collections.defaultdict(list); tally = collections.Counter(); cancel = []; chg = collections.defaultdict(list)
    for k, v in l.items():
        va = a.get(k)
        if v[0] in EQ and (va is None or va[0] not in EQ):
            lost = [n for n in (180, 181) if offs[n].get(k, ('?',))[0] not in EQ]
            tag = f'OWN{lost[0]}' if len(lost) == 1 else 'SHARED' if not lost else 'JOINT'
            tally[tag] += 1; own[tag].append(k)
        elif va is not None and va != v:
            moved = [n for n in (180, 181) if offs[n].get(k) != v]
            tag = f'OWN{moved[0]}' if len(moved) == 1 else 'SHARED' if not moved else 'JOINT'
            chg[tag].append((k, va, v))
        if va == v:
            for n in (180, 181):
                if offs[n].get(k) != v: cancel.append((k, n, v, offs[n].get(k)))
    print(f'== {st}: rows {len(l)}; conversions L vs A = {sum(tally.values())}: ' + ' '.join(f'{t}={c}' for t, c in sorted(tally.items())))
    for t in sorted(own): print(f'  CONV {t}: ' + ', '.join(nm(k) for k in sorted(own[t])))
    print(f'  CHANGE (L vs A, not a conversion): ' + ' '.join(f'{t}={len(c)}' for t, c in sorted(chg.items())))
    for t in sorted(chg):
        for k, va, v in sorted(chg[t]): print(f'    {t} {nm(k)}: A={va} L={v}')
    print(f'  CANCEL (same in L and A, different with one landing off): {len(cancel)}')
    for k, n, v, vo in cancel: print(f'    {nm(k)} off{n}: L/A={v} off={vo}')
