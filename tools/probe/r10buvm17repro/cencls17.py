#!/usr/bin/env python3
"""r10buvm17 — classify a golden-vs-ours foreach census pair.

MEASUREMENT ONLY.  LHS is ALWAYS golden, RHS is ALWAYS ours.

Joins on (subroutine full name | foreach loc | view) as a MULTISET and sorts
each site into one class:

  GOLDEN-BINDS-OURS-BARE  golden's Actual_group is set where ours is null
  OURS-BINDS-GOLDEN-BARE  the mirror -- an OVER-FIRE
  KIND-DIFF               both bind, to different object kinds
  LISTING-DIFF            vpiLoopVars itself differs (a residue, not a bind)
  REFSET-DIFF             one side has references the other does not emit
  POSITION-ONLY           identical binding; only the reference's PARENT kind
                          differs (our select/hier_path shape, a separate
                          residue -- never counted as a bind disagreement)
  AGREE

  usage: cencls17.py <golden.cen> <ours.cen> [--examples N] [--class C]
"""
import sys
import collections


def rows(p):
    out = []
    for ln in open(p):
        if not ln.startswith('FE '):
            continue
        d = {}
        for tok in ln.rstrip('\n').split(' ')[2:]:
            k, _, v = tok.partition('=')
            if k:
                d[k] = v
        out.append(d)
    return out


def parse_acts(a):
    """-> {name@line:col: (parentkind, actual)}"""
    d = {}
    if a == '<none>':
        return d
    for item in a.split(';'):
        ref, _, act = item.partition('->')
        f = ref.split(':')
        d[':'.join(f[:-1])] = (f[-1], act)
    return d


def classify(g, p):
    ga, pa = parse_acts(g['a']), parse_acts(p['a'])
    if set(ga) != set(pa):
        return 'REFSET-DIFF'
    if g['lv'] != p['lv']:
        return 'LISTING-DIFF'
    gb = {k for k, v in ga.items() if v[1] != 'BARE'}
    pb = {k for k, v in pa.items() if v[1] != 'BARE'}
    if gb - pb and not pb - gb:
        return 'GOLDEN-BINDS-OURS-BARE'
    if pb - gb and not gb - pb:
        return 'OURS-BINDS-GOLDEN-BARE'
    if gb != pb:
        return 'MIXED'
    if any(ga[k][1] != pa[k][1] for k in ga):
        return 'KIND-DIFF'
    if any(ga[k][0] != pa[k][0] for k in ga):
        return 'POSITION-ONLY'
    return 'AGREE'


def main():
    args = [x for x in sys.argv[1:] if not x.startswith('--')]
    opts = {x.split('=')[0]: (x.split('=')[1] if '=' in x else '')
            for x in sys.argv[1:] if x.startswith('--')}
    if len(args) < 2:
        print(__doc__)
        return 2
    G, P = rows(args[0]), rows(args[1])

    def key(d):
        f = d['key'].split('|')
        return ('|'.join(f[:2]), d['view'])
    gk, pk = collections.defaultdict(list), collections.defaultdict(list)
    for d in G:
        gk[key(d)].append(d)
    for d in P:
        pk[key(d)].append(d)
    c = collections.Counter()
    ex = collections.defaultdict(list)
    for k in set(gk) | set(pk):
        gl, pl = gk.get(k, []), pk.get(k, [])
        # multiset: pair up in order, surplus on either side is its own class
        for i in range(max(len(gl), len(pl))):
            if i >= len(gl):
                c[('OURS-ONLY-SITE', k[1])] += 1
                continue
            if i >= len(pl):
                c[('GOLDEN-ONLY-SITE', k[1])] += 1
                continue
            cl = classify(gl[i], pl[i])
            c[(cl, k[1])] += 1
            if cl != 'AGREE':
                ex[(cl, k[1])].append((k, gl[i], pl[i]))
    tot = collections.Counter()
    for (cl, view), n in c.items():
        tot[cl] += n
    print('  '.join('%s=%d' % (k, v) for k, v in sorted(tot.items())))
    for (cl, view), n in sorted(c.items()):
        print('   %-24s %-10s %d' % (cl, view, n))
    n = int(opts.get('--examples', 0) or 0)
    want = opts.get('--class', '')
    if n:
        for k in sorted(ex):
            if want and k[0] != want:
                continue
            for (site, g, p) in ex[k][:n]:
                print('--- %s %s [%s]' % (site[0], site[1], k[0]))
                print('  G lv=%s a=%s' % (g['lv'], g['a']))
                print('  P lv=%s a=%s' % (p['lv'], p['a']))
    return 0


sys.exit(main())
