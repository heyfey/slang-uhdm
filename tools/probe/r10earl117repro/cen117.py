#!/usr/bin/env python3
"""r10earl117 — the corpus/arm census scorer, keyed per database.

MEASUREMENT ONLY.  The official uhdm-cmp is the judge.
LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

Reads three sig117 outputs — golden, ours-pristine, ours-patched — and joins
them as MULTISETS on the KEY columns (RESUME.md section 9: a last-writer dict
drops rows; keys DO collide, so every cell is a Counter over payloads).

SHAPES, per (database, key):
  TOGOLD      pristine != golden, patched == golden          (a cell CONVERTED)
  AWAY        pristine == golden, patched != golden          (a REGRESSION)
  MOVEDWRONG  pristine != golden, patched != golden, moved   (moved, still wrong)
  STILLWRONG  pristine != golden, patched == pristine        (untouched residue)
  NOGOLD_MOVED  no golden cell at that key, and ours moved

usage: cen117.py <gold.txt> <pris.txt> <patch.txt> [--family FX|F0] [--quiet]

FAMILIES (the two census families this pass scores in):
  FX  the LAW'S OWN SURFACE — the full key, payload = (kind, rendering)
  F0  the COARSE key (drop the span) — catches a cell that MOVED its span
"""
import sys, collections

KEYCOLS = slice(2, 11)   # SPAN SK SNAME CAR SC GD PAT SIDE POS
PAYCOLS = slice(11, 13)  # IK IT


def load(path, family):
    per = collections.defaultdict(lambda: collections.defaultdict(collections.Counter))
    try:
        fh = open(path)
    except OSError:
        return per
    for line in fh:
        if not line.startswith('S|'):
            continue
        f = line.rstrip('\n').split('|')
        if len(f) < 13:
            continue
        db = f[1]
        key = tuple(f[KEYCOLS])
        if family == 'F0':
            key = key[1:]          # drop the SPAN
        per[db][key][tuple(f[PAYCOLS])] += 1
    return per


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    family = 'FX'
    for a in sys.argv[1:]:
        if a.startswith('--family'):
            family = a.split('=', 1)[1] if '=' in a else 'FX'
    quiet = '--quiet' in sys.argv
    if len(args) < 3:
        sys.exit(__doc__)
    G = load(args[0], family)
    P = load(args[1], family)
    A = load(args[2], family)

    tot = collections.Counter()
    moved_rows = collections.defaultdict(list)
    for db in sorted(set(G) | set(P) | set(A)):
        g, p, a = G.get(db, {}), P.get(db, {}), A.get(db, {})
        for key in set(g) | set(p) | set(a):
            gc, pc, ac = g.get(key), p.get(key), a.get(key)
            if gc is None:
                if pc != ac:
                    tot['NOGOLD_MOVED'] += 1
                    moved_rows['NOGOLD_MOVED'].append((db, key, pc, ac))
                continue
            pg, ag = (pc == gc), (ac == gc)
            if pg and ag:
                tot['SAME_AGREE'] += 1
            elif not pg and ag:
                tot['TOGOLD'] += 1
                moved_rows['TOGOLD'].append((db, key, pc, ac))
            elif pg and not ag:
                tot['AWAY'] += 1
                moved_rows['AWAY'].append((db, key, pc, ac))
            elif pc == ac:
                tot['STILLWRONG'] += 1
            else:
                tot['MOVEDWRONG'] += 1
                moved_rows['MOVEDWRONG'].append((db, key, pc, ac))

    print("FAMILY %s  " % family + "  ".join(
        "%s %d" % (k, tot[k]) for k in
        ('SAME_AGREE', 'TOGOLD', 'AWAY', 'MOVEDWRONG', 'STILLWRONG',
         'NOGOLD_MOVED')))
    if quiet:
        return
    for shape in ('TOGOLD', 'AWAY', 'MOVEDWRONG', 'NOGOLD_MOVED'):
        for db, key, pc, ac in moved_rows[shape]:
            print("  %-12s %-40s %s" % (shape, db, '|'.join(key)))
            print("      pris=%s  patch=%s" % (dict(pc or {}), dict(ac or {})))


if __name__ == '__main__':
    main()
