#!/usr/bin/env python3
"""r10earl120 -- the THREE-WAY SCORE of the param-copy typespec `vpiInstance`
census.

MEASUREMENT ONLY.  The official `uhdm-cmp` is the judge; this scores WHY a
database moved and in WHICH direction.

    score120.py <pristine.tsv> <patched.tsv> [--family FX|REST|ALL] [--rows]

Each input is a censweep120.sh output: rows
    <side G|O>\\t<mode>\\t<test>\\t<CELL|ROLECELL|SRC>\\t<count>\\t<key>\\t<payload>

KEY DISCIPLINE (RESUME.md section 9):
  * a MULTISET join on (mode, test, key) -> Counter(payload); a last-writer
    dict drops rows and manufactures phantoms;
  * our objects carry an EMPTY VpiFile, so no file is in the key;
  * the GOLDEN halves of the two sweeps are asserted IDENTICAL first -- if
    they are not, nothing below is attributable and the script exits 4.

FAMILIES.  Every CELL is a param-substitution constant's own typespec.
  FX   -- at least one of the three sides names a package on it: the cells
          § paPaCopyTsInstance120 can reach at all.
  REST -- all three sides are `<null>`: the fence population, which must not
          move by a single cell.

SCORING, per (mode, test, key) cell:
    TO-GOLDEN     pristine != golden, patched == golden
    AWAY-GOLDEN   pristine == golden, patched != golden      <-- must be 0
    MOVED-WRONG   pristine != golden, patched != golden, patched != pristine
    STILL-WRONG   pristine != golden, patched == pristine
    NOGOLD_*      keys golden does not hold at all

ROLECELL rows are scored SEPARATELY, under the tag `ROLE`, because the vector
role (`All[i]` vs `Top[i]`) is NOT a field any generated `Compare` reads: the
judge follows `typespec::Instance` into `package::Compare`, which reads the
package's own name and containers.  A role divergence is therefore reported
but is not an acceptance failure on its own -- and `uhdm-cmp` on the arm and
on the corpus row is what settles it either way.
"""
import sys
from collections import Counter, defaultdict


def load(path, tag):
    cells = defaultdict(Counter)
    with open(path) as f:
        for line in f:
            p = line.rstrip('\n').split('\t')
            if len(p) < 7 or p[3] != tag:
                continue
            cells[(p[0], p[1], p[2], p[5])][p[6]] += int(p[4])
    return cells


def score(pris, patc, label, show_rows, family_want='ALL'):
    gp = {k: v for k, v in pris.items() if k[0] == 'G'}
    gq = {k: v for k, v in patc.items() if k[0] == 'G'}
    if gp != gq:
        only_p = set(gp) - set(gq)
        only_q = set(gq) - set(gp)
        diff = [k for k in set(gp) & set(gq) if gp[k] != gq[k]]
        print('%s CALIBRATION FAILED: golden halves differ '
              '(only-pris %d only-pat %d payload-differs %d)'
              % (label, len(only_p), len(only_q), len(diff)))
        for k in list(only_p)[:5] + list(only_q)[:5] + diff[:5]:
            print('   ', k)
        return 4
    print('%s CALIBRATION: golden halves of the two sweeps IDENTICAL '
          '(%d keys, %d cells)'
          % (label, len(gp), sum(sum(c.values()) for c in gp.values())))

    keys = set(k[1:] for k in list(pris) + list(patc))
    tally, cellcount = Counter(), Counter()
    movers = defaultdict(Counter)
    detail = []
    for (mode, test, key) in sorted(keys):
        g = pris.get(('G', mode, test, key))
        p = pris.get(('O', mode, test, key))
        q = patc.get(('O', mode, test, key))
        pays = set()
        for c in (g, p, q):
            if c:
                pays |= set(c)
        fam = 'REST' if pays <= {'<null>'} else 'FX'
        if family_want != 'ALL' and fam != family_want:
            continue
        n = sum((q or p or g or Counter()).values())
        if g is None:
            k2 = fam + (' NOGOLD_SAME' if p == q else ' NOGOLD_MOVED')
            tally[k2] += 1
            cellcount[k2] += n
            if p != q:
                movers[(mode, test)][k2] += 1
                detail.append(('NOGOLD_MOVED', fam, mode, test, key, g, p, q))
            continue
        if p == g and q == g:
            k2 = fam + ' SAME_AGREE'
        elif p != g and q == g:
            k2 = fam + ' TO-GOLDEN'
        elif p == g and q != g:
            k2 = fam + ' AWAY-GOLDEN'
        elif q != p:
            k2 = fam + ' MOVED-WRONG'
        else:
            k2 = fam + ' STILL-WRONG'
        tally[k2] += 1
        cellcount[k2] += n
        if k2.split(' ')[1] in ('TO-GOLDEN', 'AWAY-GOLDEN', 'MOVED-WRONG'):
            movers[(mode, test)][k2] += 1
            detail.append((k2.split(' ')[1], fam, mode, test, key, g, p, q))

    print('\n-- %s TALLY (keys / cells) --' % label)
    for k in sorted(tally):
        print('  %-24s %6d keys  %8d cells' % (k, tally[k], cellcount[k]))
    print('\n-- %s MOVER ROWS (a row appears only if a cell of it moved) --' % label)
    for (mode, test) in sorted(movers):
        print('  %-10s %-30s %s' % (mode, test, dict(movers[(mode, test)])))
    if show_rows:
        print('\n-- %s DETAIL (first 40) --' % label)
        for d in detail[:40]:
            kind, fam, mode, test, key, g, p, q = d
            print('  %-12s %-4s %-9s %-24s %s' % (kind, fam, mode, test, key))
            print('        golden=%s' % (dict(g) if g else None))
            print('        pristine=%s' % (dict(p) if p else None))
            print('        patched =%s' % (dict(q) if q else None))
    print('\n%s DETAIL_TOTAL %d' % (label, len(detail)))
    return 0


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    fam = 'ALL'
    if '--family' in sys.argv:
        fam = sys.argv[sys.argv.index('--family') + 1]
    rows = '--rows' in sys.argv
    rc = 0
    for tag in ('CELL', 'ROLECELL'):
        rc |= score(load(sys.argv[1], tag), load(sys.argv[2], tag),
                    tag, rows, fam)
        print()
    return rc


if __name__ == '__main__':
    sys.exit(main())
