#!/usr/bin/env python3
"""r10buvm17 — MULTISET join of two foreach loop-variable censuses.

MEASUREMENT ONLY.  LHS is ALWAYS golden, RHS is ALWAYS ours.

Rows are keyed on `key=` (subroutine full name | foreach loc | the sorted
name@loc:parentkind shape of every loop-variable reference) plus `view=`.  The
key is a MULTISET key: two identical sites (a package emitted twice, a class
cloned per importer) collide by construction, so both sides' rows are counted
and joined by count, never dropped into a last-writer dict.

Compared cell: `lv=` (the vpiLoopVars listing) and `a=` (each reference's
Actual_group).  `hk=`/`hi=`/`ch=`/`nref=` are DIAGNOSTICS printed after the
cell and never compared -- our subroutines and expressions carry different
VpiFile/instance decorations, which says nothing about binding.

  usage: cenjoin17.py <golden.cen> <ours.cen> [--lv] [--verbose N]
         --lv     compare the LISTING (lv=) too, not only the actuals
         --only-elab / --only-def  restrict to one view
"""
import sys
from collections import Counter, defaultdict


def load(path, cmp_lv):
    rows = Counter()
    for ln in open(path):
        if not ln.startswith('FE '):
            continue
        f = ln.rstrip('\n').split(' ')
        d = {}
        # key= and a= may contain '=' but never a space; fields are space-split.
        for tok in f[2:]:
            if '=' in tok:
                k, _, v = tok.partition('=')
                d[k] = v
        # THE SHAPE IS PART OF THE VALUE, NOT THE KEY.  Keying on it splits a
        # site whose reference SET differs between the two sides into two
        # one-sided keys that read as "no disagreement" -- 159 of them on the
        # first cut of this join, all of them real (our unparented expression
        # nodes drop out of the attribution).  The key is the SITE.
        kf = d.get('key', '?').split('|')
        key = ('|'.join(kf[:2]), d.get('view', '?'))
        val = d.get('a', '?')
        if cmp_lv:
            val = d.get('lv', '?') + ' || ' + val
        rows[(key, val)] += 1
    return rows


def main():
    a = [x for x in sys.argv[1:] if not x.startswith('--')]
    opts = [x for x in sys.argv[1:] if x.startswith('--')]
    if len(a) < 2:
        print(__doc__)
        return 2
    cmp_lv = '--lv' in opts
    verbose = 0
    for o in opts:
        if o.startswith('--verbose'):
            verbose = int(o.split('=')[1]) if '=' in o else 20
    G, P = load(a[0], cmp_lv), load(a[1], cmp_lv)
    if '--only-elab' in opts or '--only-def' in opts:
        want = 'ELABPKG' if '--only-elab' in opts else 'DEFPKG'
        G = Counter({k: v for k, v in G.items() if k[0][1] == want})
        P = Counter({k: v for k, v in P.items() if k[0][1] == want})
    gk, pk = defaultdict(Counter), defaultdict(Counter)
    for (key, val), n in G.items():
        gk[key][val] += n
    for (key, val), n in P.items():
        pk[key][val] += n
    agree = dis = gonly = ponly = 0
    ex = []
    for key in set(gk) | set(pk):
        gv, pv = gk.get(key, Counter()), pk.get(key, Counter())
        if not pv:
            gonly += sum(gv.values())
            continue
        if not gv:
            ponly += sum(pv.values())
            continue
        common = gv & pv          # multiset intersection
        agree += sum(common.values())
        gl, pl = gv - common, pv - common
        n = sum(gl.values())
        dis += n
        if n and len(ex) < verbose:
            ex.append((key, list(gl.elements()), list(pl.elements())))
    print('AGREE=%d DISAGREE=%d GOLDEN-ONLY-KEY=%d OURS-ONLY-KEY=%d keys=%d'
          % (agree, dis, gonly, ponly, len(set(gk) | set(pk))))
    for key, gl, pl in ex:
        print('--- key=%s view=%s' % key)
        for x in gl:
            print('  G %s' % x)
        for x in pl:
            print('  P %s' % x)
    return 0


sys.exit(main())
