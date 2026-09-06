#!/usr/bin/env python3
"""r10v104 three-way score: golden vs pristine vs patched, per param_assign cell.
Refuses to score unless the GOLDEN side is identical between the two runs."""
import sys, os
PROJ = os.environ.get('PROJ', 'full')

def load(p):
    d = {}
    if not os.path.exists(p):
        return d
    for ln in open(p):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 6:
            continue
        v = (f[3], f[4], f[5])
        if PROJ == 'ts':
            v = (f[3], f[4])
        elif PROJ == 'enc':
            v = (f[3], f[5])
        d[(f[0], f[1], f[2])] = v
    return d

def main(prisdir, patdir, arms, verbose=False, only=None):
    tot = dict(AWAY=0, TOGOLD=0, MOVEDWRONG=0, STILLWRONG=0, UNMOVEDGOOD=0,
               ADDED=0, REMOVED=0)
    rows = []
    for arm in arms:
        gp = load(os.path.join(prisdir, arm, 'g.cen'))
        gq = load(os.path.join(patdir, arm, 'g.cen'))
        if gp != gq:
            print(f'!! {arm}: GOLDEN SIDE DIFFERS between runs -- refusing to score')
            for k in sorted(set(gp) | set(gq)):
                if gp.get(k) != gq.get(k):
                    print('   ', k, gp.get(k), '||', gq.get(k))
            continue
        op = load(os.path.join(prisdir, arm, 'o.cen'))
        oq = load(os.path.join(patdir, arm, 'o.cen'))
        keys = set(gp) & (set(op) | set(oq))
        for k in sorted(keys):
            g = gp.get(k); a = op.get(k); b = oq.get(k)
            if a is None: tot['ADDED'] += 1; continue
            if b is None: tot['REMOVED'] += 1; continue
            if a == b:
                if b == g: tot['UNMOVEDGOOD'] += 1
                else:
                    tot['STILLWRONG'] += 1
                    rows.append(('STILL-WRONG', arm, k, g, a, b))
                continue
            if a == g and b != g:
                tot['AWAY'] += 1; rows.append(('AWAY-GOLDEN', arm, k, g, a, b))
            elif a != g and b == g:
                tot['TOGOLD'] += 1; rows.append(('TO-GOLDEN', arm, k, g, a, b))
            else:
                tot['MOVEDWRONG'] += 1
                rows.append(('MOVED-WRONG', arm, k, g, a, b))
    print('SCORE ' + ' '.join(f'{k}={v}' for k, v in tot.items()))
    for r in rows:
        if only and r[0] not in only:
            continue
        print(f'{r[0]:12s} {r[1]:16s} {r[2][0]:5s} {r[2][1]} @{r[2][2]}')
        print(f'      golden : {r[3][0]} | {r[3][1]}')
        print(f'      pris   : {r[4][0]} | {r[4][1]}')
        print(f'      patched: {r[5][0]} | {r[5][1]}')
    return tot

if __name__ == '__main__':
    prisdir, patdir = sys.argv[1], sys.argv[2]
    arms = sys.argv[3:]
    only = None
    if arms and arms[0].startswith('--only='):
        only = set(arms[0][7:].split(',')); arms = arms[1:]
    if not arms:
        arms = sorted(d for d in os.listdir(prisdir)
                      if os.path.isdir(os.path.join(prisdir, d)))
    main(prisdir, patdir, arms, only=only)
