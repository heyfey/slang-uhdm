#!/usr/bin/env python3
"""r10uvm167repro/score167.py — score a census triple.  MEASUREMENT ONLY.

    score167.py <cen.g.txt> <cen.a.txt> <cen.b.txt> [--list] [--fam CALL]

LHS is ALWAYS golden (Surelog); A is the PRISTINE binary, B the PATCHED one.

THE KEY.  The RUN TAG is part of every row (r10uvm166 §6: merging the DEF-view
and ELAB-view databases into one multiset manufactures phantom RESHAPE-AWAY
cells).  The tag is `G.<view>` on golden and `O.<view>` on ours, so the SIDE is
normalised out and the VIEW stays in.  The key never replaces the NAME with a
span.

THE VALUE.  A `CALL|` row's ARGUMENT-VECTOR SIZE is the thing this pass moves,
so it is scored as the cell's VALUE, not as part of its identity: a call whose
vector goes 7 -> 5 is ONE cell that MOVED, not one cell deleted and one
inserted.  (Keeping `N=` in the key scored the head's own family as
`4 AWAY + 4 TOWARD` on arm A, which is the same four objects counted twice.)
`ARG|` and `OBJ|` rows carry no value: they are pure identity multisets.

VERDICTS, per key:
    TOWARD    A disagreed with golden, B agrees
    AWAY      A agreed with golden, B does not              <-- must be 0
    WRONG     A and B both disagree, and B != A             <-- must be 0
    STILL     A == B (agreeing or not): unmoved
    ORPHAN    the key does not exist in GOLDEN AT ALL (a pre-existing SHAPE
              residue: an object golden never built) and its value moved.
              Neither toward nor away is measurable, so these are LISTED and
              accounted for BY NAME rather than counted green.
"""
import sys, collections

VALUED = ('CALL',)


def load(path):
    keys = collections.Counter()          # identity multiset (ARG/OBJ + CALL keys)
    vals = collections.defaultdict(collections.Counter)   # CALL key -> {N: count}
    for line in open(path, errors='replace'):
        line = line.rstrip('\n')
        if not line:
            continue
        f = line.split('|')
        if len(f) < 3:
            continue
        f[1] = f[1].split('.', 1)[1] if '.' in f[1] else f[1]
        if f[0] in VALUED and f[-1].startswith('N='):
            k = '|'.join(f[:-1])
            vals[k][f[-1]] += 1
            keys[k] += 1
        else:
            keys['|'.join(f)] += 1
    return keys, vals


def main():
    (gk, gv), (ak, av), (bk, bv) = (load(p) for p in sys.argv[1:4])
    lst = '--list' in sys.argv
    fam = None
    if '--fam' in sys.argv:
        fam = sys.argv[sys.argv.index('--fam') + 1]
    allk = set(gk) | set(ak) | set(bk)
    if fam:
        allk = {k for k in allk if k.split('|', 1)[0] == fam}
    v = collections.Counter()
    rows = []
    for k in sorted(allk):
        valued = k.split('|', 1)[0] in VALUED
        if valued:
            G, A, B = gv[k], av[k], bv[k]
            # the cell's COUNT must be compared too, so fold it in
            G = (gk[k], tuple(sorted(G.items())))
            A = (ak[k], tuple(sorted(A.items())))
            B = (bk[k], tuple(sorted(B.items())))
        else:
            G, A, B = gk[k], ak[k], bk[k]
        if A == B:
            v['STILL'] += 1
            continue
        empty = (0, ()) if valued else 0
        if B == G:
            verdict = 'TOWARD'
        elif A == G:
            verdict = 'AWAY'
        elif valued:
            # RESHAPE: the cell's COUNT is a pre-existing listing residue (the
            # elaborated database duplicates a generic-class body a different
            # number of times), so score the VALUE SET on its own.
            sg = set(x for x, _ in G[1])
            sa = set(x for x, _ in A[1])
            sb = set(x for x, _ in B[1])
            if sb == sg and sa != sg:
                verdict = 'RESHAPE-TOWARD'
            elif sa == sg and sb != sg:
                verdict = 'RESHAPE-AWAY'
            elif G == empty:
                verdict = 'ORPHAN'
            else:
                verdict = 'WRONG'
        elif G == empty:
            verdict = 'ORPHAN'
        else:
            verdict = 'WRONG'
        v[verdict] += 1
        rows.append((verdict, k, G, A, B))
    for name in ('TOWARD', 'RESHAPE-TOWARD', 'AWAY', 'RESHAPE-AWAY', 'WRONG',
                 'ORPHAN', 'STILL'):
        print('%-8s %d' % (name, v[name]))
    if lst:
        for verdict, k, G, A, B in rows:
            print('  %-8s G=%s A=%s B=%s  %s' % (verdict, G, A, B, k))
    print('-- MOVED-TOWARD=%d  MOVED-WRONG/AWAY=%d  ORPHAN=%d'
          % (v['TOWARD'] + v['RESHAPE-TOWARD'],
             v['AWAY'] + v['RESHAPE-AWAY'] + v['WRONG'], v['ORPHAN']))
    return 0


sys.exit(main())
