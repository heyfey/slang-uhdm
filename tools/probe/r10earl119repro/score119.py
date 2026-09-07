#!/usr/bin/env python3
"""r10earl119 -- the THREE-WAY SCORE of the cont_assign Rhs-shape census.

MEASUREMENT ONLY.  The official uhdm-cmp is the judge; this scores WHY a
database moved and in WHICH direction.

    score119.py <pristine.tsv> <patched.tsv> [--family FX|REST|ALL]

Each input is a censweep118.sh output: rows
    <side G|O>\t<mode>\t<test>\tCELL\t<count>\t<key>\t<payload>
(VIEWCELL rows are diagnostics and are ignored here).

KEY DISCIPLINE (RESUME.md section 9):
  * the census is a MULTISET JOIN on (mode, test, key) -> Counter of payloads;
    a last-writer dict drops rows and manufactures phantoms;
  * the DEF/ELAB view is NOT in the key (the two producers label it
    differently) -- cen119 emits it only on its diagnostic VIEWCELL rows;
  * the GOLDEN halves of the two sweeps are asserted IDENTICAL first.  If they
    are not, nothing below is attributable and the script says so and exits 4.

SCORING, per (mode, test, key) cell:
    TO-GOLDEN     pristine != golden, patched == golden
    AWAY-GOLDEN   pristine == golden, patched != golden      <-- must be 0
    MOVED-WRONG   pristine != golden, patched != golden, patched != pristine
    STILL-WRONG   pristine != golden, patched == pristine
    NOGOLD_*      keys golden does not hold at all
FAMILY FX is this pass's own: a gen_scope-homed key whose Lhs kind is a plain
`ref_obj` -- the only cells `applyCaCastFoldDef119` can reach at all (the walk
visits gen scopes only and skips any Lhs that is not a `ref_obj`).  REST is
every other key, and it must not move by a single cell.
"""
import sys
from collections import Counter, defaultdict


def load(path):
    cells = defaultdict(Counter)   # (side, mode, test, key) -> Counter(payload)
    with open(path) as f:
        for line in f:
            p = line.rstrip('\n').split('\t')
            if len(p) < 7 or p[3] != 'CELL':
                continue
            side, mode, test, _tag, cnt, key, pay = p[0], p[1], p[2], p[3], p[4], p[5], p[6]
            cells[(side, mode, test, key)][pay] += int(cnt)
    return cells


def family(key):
    parts = key.split('|')
    if len(parts) >= 4 and parts[1] == 'gen_scope' and parts[3] == 'ref_obj':
        return 'FX'
    return 'REST'


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    pris = load(sys.argv[1])
    patc = load(sys.argv[2])
    want = 'ALL'
    if '--family' in sys.argv:
        want = sys.argv[sys.argv.index('--family') + 1]

    # 1. CALIBRATION: the golden halves of the two sweeps must be identical.
    gp = {k: v for k, v in pris.items() if k[0] == 'G'}
    gq = {k: v for k, v in patc.items() if k[0] == 'G'}
    if gp != gq:
        only_p = set(gp) - set(gq)
        only_q = set(gq) - set(gp)
        diff = [k for k in set(gp) & set(gq) if gp[k] != gq[k]]
        print('CALIBRATION FAILED: golden halves differ')
        print('  only-in-pristine-sweep %d  only-in-patched-sweep %d  payload-differs %d'
              % (len(only_p), len(only_q), len(diff)))
        for k in list(only_p)[:5] + list(only_q)[:5] + diff[:5]:
            print('   ', k)
        return 4
    print('CALIBRATION: golden halves of the two sweeps IDENTICAL '
          '(%d keys, %d cells)' % (len(gp), sum(sum(c.values()) for c in gp.values())))

    keys = set(k[1:] for k in list(pris) + list(patc))
    tally = Counter()
    cellcount = Counter()
    movers = defaultdict(Counter)
    detail = []
    for (mode, test, key) in sorted(keys):
        fam = family(key)
        if want != 'ALL' and fam != want:
            continue
        g = pris.get(('G', mode, test, key))
        p = pris.get(('O', mode, test, key))
        q = patc.get(('O', mode, test, key))
        n = sum((q or p or g or Counter()).values())
        if g is None:
            if p == q:
                tally[fam + ' NOGOLD_SAME'] += 1
                cellcount[fam + ' NOGOLD_SAME'] += n
            else:
                tally[fam + ' NOGOLD_MOVED'] += 1
                cellcount[fam + ' NOGOLD_MOVED'] += n
                movers[(mode, test)][fam + ' NOGOLD_MOVED'] += 1
                detail.append(('NOGOLD_MOVED', fam, mode, test, key, g, p, q))
            continue
        if p == g and q == g:
            tally[fam + ' SAME_AGREE'] += 1
            cellcount[fam + ' SAME_AGREE'] += n
        elif p != g and q == g:
            tally[fam + ' TO-GOLDEN'] += 1
            cellcount[fam + ' TO-GOLDEN'] += n
            movers[(mode, test)][fam + ' TO-GOLDEN'] += 1
            detail.append(('TO-GOLDEN', fam, mode, test, key, g, p, q))
        elif p == g and q != g:
            tally[fam + ' AWAY-GOLDEN'] += 1
            cellcount[fam + ' AWAY-GOLDEN'] += n
            movers[(mode, test)][fam + ' AWAY-GOLDEN'] += 1
            detail.append(('AWAY-GOLDEN', fam, mode, test, key, g, p, q))
        elif q != p:
            tally[fam + ' MOVED-WRONG'] += 1
            cellcount[fam + ' MOVED-WRONG'] += n
            movers[(mode, test)][fam + ' MOVED-WRONG'] += 1
            detail.append(('MOVED-WRONG', fam, mode, test, key, g, p, q))
        else:
            tally[fam + ' STILL-WRONG'] += 1
            cellcount[fam + ' STILL-WRONG'] += n

    print('\n-- TALLY (keys / cells) --')
    for k in sorted(tally):
        print('  %-22s %6d keys  %8d cells' % (k, tally[k], cellcount[k]))
    print('\n-- MOVER ROWS (a row appears only if a cell of it moved) --')
    for (mode, test) in sorted(movers):
        print('  %-10s %-28s %s' % (mode, test, dict(movers[(mode, test)])))
    print('\n-- DETAIL (first 60) --')
    for d in detail[:60]:
        kind, fam, mode, test, key, g, p, q = d
        print('  %-12s %-4s %-9s %-24s %s' % (kind, fam, mode, test, key))
        print('        golden=%s' % (dict(g) if g else None))
        print('        pristine=%s' % (dict(p) if p else None))
        print('        patched =%s' % (dict(q) if q else None))
    print('\nDETAIL_TOTAL %d' % len(detail))
    return 0


if __name__ == '__main__':
    sys.exit(main())
