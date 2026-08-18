#!/usr/bin/env python3
"""r10rgg8/score.py -- the three-side join over the grid.

  usage: score.py <griddir> [<label> ...]

Prints, per cell and per SITE (view, scope, role, line:col, name), golden's
shape and each labelled binary's shape, and an ORDER-BLIND verdict:

  OK      golden == label          (already right)
  FIXED   base != golden == label   (only with base+pat labels)
  BROKEN  base == golden != label   (a pristine-right cell the patch broke)
  STILL   base != golden != label   (still wrong)
  NOGOLD / NOSIDE  a side produced no row for this site -- COUNTED, never
                   silently treated as agreement.
"""
import os, sys, collections

def load(p):
    d = {}
    if not os.path.exists(p):
        return None
    for ln in open(p):
        ln = ln.rstrip('\n')
        if not ln:
            continue
        f = ln.split('\t')
        if len(f) < 6:
            continue
        d[tuple(f[:5])] = f[5]
    return d

def main():
    gd = sys.argv[1]
    labels = sys.argv[2:]
    cells = sorted(x for x in os.listdir(gd) if os.path.isdir(os.path.join(gd, x)))
    counts = collections.Counter()
    print("CELL\tSITE\tGOLDEN\t" + "\t".join(labels))
    for c in cells:
        g = load(os.path.join(gd, c, 'gold.sites'))
        ls = {l: load(os.path.join(gd, c, l + '.sites')) for l in labels}
        if not g:
            print(f"{c}\t-\tNOGOLD")
            counts['NOGOLD'] += 1
            continue
        keys = set(g)
        for l in labels:
            if ls[l]:
                keys |= set(ls[l])
        for k in sorted(keys):
            gv = g.get(k, '<NOROW>')
            vs = [(ls[l] or {}).get(k, '<NOROW>') for l in labels]
            same = all(v == gv for v in vs)
            print(f"{c}\t{'|'.join(k)}\t{gv}\t" + "\t".join(vs))
            if len(labels) == 2:
                b, p = vs
                if b == gv and p == gv:
                    counts['OK'] += 1
                elif b != gv and p == gv:
                    counts['FIXED'] += 1
                elif b == gv and p != gv:
                    counts['BROKEN'] += 1
                else:
                    counts['STILL'] += 1
            elif labels:
                counts['SAME' if same else 'DIFF'] += 1
    print("-- " + "  ".join(f"{k}={v}" for k, v in sorted(counts.items())))

if __name__ == '__main__':
    main()
