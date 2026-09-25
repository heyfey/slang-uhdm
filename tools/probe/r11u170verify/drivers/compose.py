#!/usr/bin/env python3
"""compose.py <L> <A> <off158> <off160> <off163>: the composition census over the gate csvs (probe, surelog,
uhdm2rtlil) of five sweeps: L = HEAD, A = the three landings off, and one landing off at a time.
Per row judge-equal-strict in L (CMP_EQUAL / EQUAL) but not in A: the landings whose single-off sweep loses
it (OWN n: exactly one; SHARED: none - any landing alone keeps it; JOINT a+b: more than one needed).
CANCEL: a row whose (status, strict) is the same in L and A but differs in a single-off sweep (a pair of laws
cancelling).  Rows of the fenced tests are skipped unread (fail-closed on $FENCED)."""
import csv, os, sys, collections
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('compose.py: source drivers/env.sh first')
L, A, O8, O0, O3 = sys.argv[1:6]
OFF = {158: O8, 160: O0, 163: O3}
def load(wd, st):
    p = f'{wd}/{st}.csv'
    if not os.path.exists(p): return None
    if st == 'probe': return {r['case']: (r['status'], r['strict']) for r in csv.DictReader(open(p))}
    return {(r['name'], r['mode']): (r['status'], r['strict']) for r in csv.DictReader(open(p)) if r['name'] not in FENCED}
EQ = ('CMP_EQUAL', 'EQUAL')
for st in ('probe', 'surelog', 'uhdm2rtlil'):
    l, a = load(L, st), load(A, st); offs = {n: load(w, st) for n, w in OFF.items()}
    if not (l and a and all(offs.values())): print(f'== {st}: missing csv'); continue
    own = collections.defaultdict(list); tally = collections.Counter(); cancel = []
    for k, v in l.items():
        va = a.get(k)
        if v[0] in EQ and (va is None or va[0] not in EQ):
            lost = [n for n in (158, 160, 163) if offs[n].get(k, ('?',))[0] not in EQ]
            tag = f'OWN{lost[0]}' if len(lost) == 1 else 'SHARED' if not lost else 'JOINT' + '+'.join(map(str, lost))
            tally[tag] += 1; own[tag].append(k)
        if va == v:
            for n in (158, 160, 163):
                if offs[n].get(k) != v: cancel.append((k, n, v, offs[n].get(k)))
    print(f'== {st}: conversions L vs A = {sum(tally.values())}: ' + ' '.join(f'{t}={c}' for t, c in sorted(tally.items())))
    for t in sorted(own):
        print(f'  {t}: ' + ', '.join((k if isinstance(k, str) else f'{k[0]}/{k[1][0]}') for k in sorted(own[t])))
    print(f'  CANCEL (same in L and A, different with one landing off): {len(cancel)}')
    for k, n, v, vo in cancel: print(f'    {k} off{n}: L/A={v} off={vo}')
