#!/usr/bin/env python3
"""r10uvm133 — JOIN two or three query-call censuses on the cell START.

Both producers anchor a type-query cell — kept `sys_func_call` or folded
`constant` — at the `$` of the written call, so the START line:col is a
producer-independent cell key.  The join is a MULTISET join (a key collides
whenever a listing is emitted twice — the DEF and ELAB copies of a class body —
and a last-writer dict would drop rows).

  usage: qjoin133.py <g.dump> <ours.dump> [<pat.dump>] [--rows]

A census CELL is a SITE (one written call, keyed line:col).  A site that a
listing emits more than once - the DEF and ELAB copies of a class body, or one
module instantiated three times - is ONE cell; the per-side copy counts ride
along in the row as gkeep=/gfold=/okeep=/ofold=.

Prints per-KIND counts of

  BOTHKEEP  BOTHFOLD  GOLDKEEP-OURSFOLD  GOLDFOLD-OURSKEEP  ONLYGOLD  ONLYOURS

and, with a third dump, the same for the patched side plus the score
TOGOLD / MOVEDWRONG / AWAY.  LHS IS ALWAYS GOLDEN.
"""
import sys, collections
import qcen133

def state(path):
    d = collections.defaultdict(list)
    for start, nm, st, ak, an in qcen133.cells(path):
        d[start].append((nm, st, ak, an))
    return d

def classify(G, O):
    keys = set(G) | set(O)
    out = collections.Counter()
    rows = []
    for k in sorted(keys):
        g = [c for c in G.get(k, []) if c[1] == 'KEPT']
        gc = [c for c in G.get(k, []) if c[1] == 'CONST']
        o = [c for c in O.get(k, []) if c[1] == 'KEPT']
        oc = [c for c in O.get(k, []) if c[1] == 'CONST']
        if not g and not o:
            continue                     # neither side kept a query call here
        kind = (g or o)[0][2]
        nm = (g or o)[0][0]
        if g and o:
            v = 'BOTHKEEP'
        elif g and oc:
            v = 'GOLDKEEP-OURSFOLD'
        elif g and not o and not oc:
            v = 'ONLYGOLD'
        elif o and gc:
            v = 'GOLDFOLD-OURSKEEP'
        else:
            v = 'ONLYOURS'
        out[(nm, kind, v)] += 1
        rows.append((k, nm, kind, v, (g or o)[0][3],
                     f'gkeep={len(g)} gfold={len(gc)} okeep={len(o)} ofold={len(oc)}'))
    return out, rows

if __name__ == '__main__':
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    showrows = '--rows' in sys.argv
    G, O = state(args[0]), state(args[1])
    cO, rO = classify(G, O)
    for key in sorted(cO):
        print(f'OURS\t{key[0]}\t{key[1]}\t{key[2]}\t{cO[key]}')
    if showrows:
        for r in rO:
            if r[3] != 'BOTHKEEP':
                print(f'ROW-OURS\t{r[0]}\t{r[1]}\t{r[2]}\t{r[3]}\t{r[4]}\t{r[5]}')
    if len(args) > 2:
        P = state(args[2])
        cP, rP = classify(G, P)
        for key in sorted(cP):
            print(f'PAT\t{key[0]}\t{key[1]}\t{key[2]}\t{cP[key]}')
        dO = {r[0]: r[3] for r in rO}
        dP = {r[0]: r[3] for r in rP}
        sc = collections.Counter()
        for k in set(dO) | set(dP):
            a, b = dO.get(k, 'ABSENT'), dP.get(k, 'ABSENT')
            if a != 'BOTHKEEP' and b == 'BOTHKEEP':
                sc['TOGOLD'] += 1
            elif a == 'BOTHKEEP' and b != 'BOTHKEEP':
                sc['AWAY' if b == 'GOLDFOLD-OURSKEEP' else 'MOVEDWRONG'] += 1
            elif a != b:
                sc['MOVEDOTHER'] += 1
            elif a != 'BOTHKEEP':
                sc['STILLWRONG'] += 1
        print('SCORE\t' + ' '.join(f'{k}={v}' for k, v in sorted(sc.items())))
