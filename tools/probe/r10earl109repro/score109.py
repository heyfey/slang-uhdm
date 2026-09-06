#!/usr/bin/env python3
"""r10earl109 -- the THREE-WAY census scorer.  MEASUREMENT ONLY.

Joins golden x pristine x patched cen109 rows per arm (or per database) as a
MULTISET on the row KEY and scores each cell:

  TO-GOLDEN      pristine != golden, patched == golden        (a WIN)
  AWAY-GOLDEN    pristine == golden, patched != golden        (a REGRESSION)
  STILL-WRONG    pristine != golden, patched != golden, moved
  UNMOVED-WRONG  pristine != golden, patched == pristine
  BOTH-SAME      pristine == golden == patched
  ONLY-GOLDEN / ONLY-OURS   one-sided keys (printed, never scored as flips)

REFUSES to score two runs whose GOLDEN side differs (RESUME section 9: a census
re-scored over a shifted universe measures nothing).  Keys are joined as a
MULTISET -- a last-writer dict silently drops colliding rows.

usage: score109.py <gold.txt> <pris.txt> <patch.txt> [more triples...]
       score109.py --dirs <griddir>            (walks <arm>_<view>/cen.*.txt)
"""
import sys, os, collections


def load(path):
    """rows -> Counter[(key, payload)] plus Counter[key] for one-sided sets."""
    rows = collections.Counter()
    if not os.path.exists(path):
        return None
    rc = None
    for ln in open(path, errors='replace'):
        if ln.startswith('CENRC '):
            rc = ln.split()[1].strip()
        if not ln.startswith('ROW\t'):
            continue
        f = ln.rstrip('\n').split('\t')
        # ROW <tag> <carrier> <tskind> <dim> <boundspan> <payload>
        if len(f) < 7:
            continue
        key = '\t'.join(f[1:6])
        rows[(key, f[6])] += 1
    if rc != '0':
        print('  CENRC-BAD %s rc=%s' % (path, rc))
        return None
    return rows


def bykey(rows):
    """key -> SET of distinct payloads.

    DEDUPED, deliberately.  A shared typespec is reached by several carriers
    and our arena sometimes holds one more copy of a carrier than golden's
    does; comparing MULTIPLICITIES turns that pre-existing parenting residue
    into a phantom flip on every row (measured: g2's ep_o / in_stall_i read
    UNMOVED-WRONG at ours=3 vs gold=2 with IDENTICAL payloads).  The judge
    reads the payload, never the count of carriers.
    """
    d = collections.defaultdict(set)
    for (k, p), n in rows.items():
        d[k].add(p)
    return d


def score(tag, g, p, a, detail=True):
    G, P, A = bykey(g), bykey(p), bykey(a)
    keys = set(G) | set(P) | set(A)
    c = collections.Counter()
    lines = []
    for k in sorted(keys):
        gk, pk, ak = G.get(k, set()), P.get(k, set()), A.get(k, set())
        if not gk:
            c['ONLY-OURS'] += 1
            continue
        if not pk and not ak:
            c['ONLY-GOLDEN'] += 1
            continue
        pe, ae = (pk == gk), (ak == gk)
        if pe and ae:
            c['BOTH-SAME'] += 1
        elif not pe and ae:
            c['TO-GOLDEN'] += 1
            lines.append('  TO-GOLDEN   %s\n      pris  %s\n      gold  %s' %
                         (k, sorted(pk), sorted(gk)))
        elif pe and not ae:
            c['AWAY-GOLDEN'] += 1
            lines.append('  AWAY-GOLDEN %s\n      gold  %s\n      patch %s' %
                         (k, sorted(gk), sorted(ak)))
        elif pk == ak:
            c['UNMOVED-WRONG'] += 1
            lines.append('  UNMOVED-WRONG %s\n      ours  %s\n      gold  %s' %
                         (k, sorted(pk), sorted(gk)))
        else:
            c['STILL-WRONG'] += 1
            lines.append('  STILL-WRONG %s\n      pris  %s\n      patch %s\n'
                         '      gold  %s' % (k, sorted(pk), sorted(ak), sorted(gk)))
    print('%-24s ' % tag + '  '.join('%s %d' % (n, c[n]) for n in
          ('BOTH-SAME', 'TO-GOLDEN', 'AWAY-GOLDEN', 'STILL-WRONG',
           'UNMOVED-WRONG', 'ONLY-GOLDEN', 'ONLY-OURS')))
    if detail:
        for l in lines:
            print(l)
    return c


def main():
    tot = collections.Counter()
    if sys.argv[1] == '--dirs':
        root = sys.argv[2]
        detail = '--quiet' not in sys.argv
        for d in sorted(os.listdir(root)):
            p = os.path.join(root, d)
            if not os.path.isdir(p):
                continue
            g = load(os.path.join(p, 'cen.gold.txt'))
            r = load(os.path.join(p, 'cen.pris.txt'))
            a = load(os.path.join(p, 'cen.patch.txt'))
            if g is None or r is None or a is None:
                print('%-24s SKIP (missing or CENRC-bad census)' % d)
                continue
            tot += score(d, g, r, a, detail)
    else:
        args = sys.argv[1:]
        for i in range(0, len(args), 3):
            g, r, a = (load(x) for x in args[i:i + 3])
            tot += score(os.path.basename(args[i]), g, r, a)
    print('-- TOTAL ' + '  '.join('%s %d' % (n, tot[n]) for n in
          ('BOTH-SAME', 'TO-GOLDEN', 'AWAY-GOLDEN', 'STILL-WRONG',
           'UNMOVED-WRONG', 'ONLY-GOLDEN', 'ONLY-OURS')))


if __name__ == '__main__':
    main()
