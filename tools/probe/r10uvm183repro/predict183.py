#!/usr/bin/env python3
"""r10uvm183 — score the A-PRIORI prediction.  PRISTINE DATABASES AND GOLDENS
ONLY; nothing here ever opens a patched binary or a patched database.

TWO INDEPENDENT PREDICTORS, required to AGREE:

  OURS-SIDE (the law's own shape) — a row moves iff OUR pristine database holds
      a `foreach` whose (line:col, enclosing subroutine) key occurs under TWO
      OR MORE DIFFERENT PACKAGE scopes.  One source line listed under two
      packages is a WILDCARD-IMPORT CLONE and nothing else, and the law fires
      exactly while such a clone body is being emitted.

  GOLDEN-SIDE — a row moves iff GOLDEN holds a package-scope `foreach`
      array-reference `unsupported_typespec` whose `vpiInstance` package NAME
      differs from its own enclosing package (golden's clone stamp), and our
      multiset does not already contain that exact cell.

The script asserts a NONZERO comparable-row count: a predictor that reaches
nothing must never read as "no movers" (RESUME.md §9).

Usage: predict183.py <outdir-of-predict183.sh>
"""
import collections
import os
import re
import sys


def load(path):
    rows = []
    if not os.path.exists(path):
        return None
    with open(path) as f:
        for line in f:
            p = line.rstrip('\n').split('\t')
            if len(p) < 8 or p[0] != 'FE':
                continue
            scope = p[3]
            skind, _, srest = scope.partition(':')
            sname = re.sub(r'#\d+$', '', srest)
            arrts = p[5].split('=', 1)[1]
            tskind = arrts.split('(', 1)[0]
            inst = re.sub(r'#\d+', '', p[6].split('=', 1)[1])
            ikind, _, iname = inst.partition(':')
            rows.append({'key': (p[1], p[2]), 'skind': skind, 'sname': sname,
                         'tskind': tskind, 'arrts': arrts,
                         'ikind': ikind, 'iname': iname})
    return rows


def cellset(rows):
    c = collections.Counter()
    for r in rows:
        c[(r['key'], r['skind'], r['sname'], r['arrts'],
           r['ikind'] + ':' + r['iname'])] += 1
    return c


def main():
    outdir = sys.argv[1]
    rows = []
    with open(os.path.join(outdir, 'rows.txt')) as f:
        for line in f:
            mode, name = line.split()
            rows.append((mode, name))
    assert rows, 'no comparable rows — the predictor reached nothing'
    ours_pred, gold_pred = set(), set()
    detail = {}
    for mode, name in rows:
        g = load(os.path.join(outdir, '%s.%s.golden.tsv' % (mode, name)))
        o = load(os.path.join(outdir, '%s.%s.pris.tsv' % (mode, name)))
        if g is None or o is None:
            print('MISSING %s/%s' % (mode, name))
            continue
        # ---- ours-side: one foreach key listed under two PACKAGE scopes ----
        bykey = collections.defaultdict(set)
        for r in o:
            if r['skind'] == 'package':
                bykey[r['key']].add(r['sname'])
        clone_keys = {k: v for k, v in bykey.items() if len(v) > 1}
        if clone_keys:
            ours_pred.add((mode, name))
        # ---- golden-side: a clone-stamped package-scope placeholder ---------
        oc = cellset(o)
        gclone = collections.Counter()
        for r in g:
            if (r['skind'] == 'package' and
                    r['tskind'] == 'unsupported_typespec' and
                    r['ikind'] == 'package' and r['iname'] != r['sname']):
                cell = (r['key'], r['skind'], r['sname'], r['arrts'],
                        r['ikind'] + ':' + r['iname'])
                if oc[cell] == 0:
                    gclone[cell] += 1
        if gclone:
            gold_pred.add((mode, name))
        detail[(mode, name)] = (len(clone_keys), sum(gclone.values()))
    print('comparable rows=%d' % len(rows))
    print('OURS-SIDE predicted moving rows=%d' % len(ours_pred))
    print('GOLDEN-SIDE predicted moving rows=%d' % len(gold_pred))
    print('AGREE=%s' % (ours_pred == gold_pred))
    for k in sorted(ours_pred | gold_pred):
        ck, gc = detail[k]
        print('  MOVER %-10s %-16s clone-foreach-keys=%-4d golden-clone-cells=%d'
              % (k[0], k[1], ck, gc))
    only_o = ours_pred - gold_pred
    only_g = gold_pred - ours_pred
    if only_o:
        print('  ONLY-OURS-SIDE: %s' % sorted(only_o))
    if only_g:
        print('  ONLY-GOLDEN-SIDE: %s' % sorted(only_g))


main()
