#!/usr/bin/env python3
"""r10uvm217 — THE A-PRIORI MOVER PREDICTION, from PRISTINE databases alone.

MEASUREMENT ONLY.  The official `uhdm-cmp` / `scripts/verify_golden.py` are the
judges; this only reports.  LHS is ALWAYS golden, RHS is ALWAYS ours.

§ `transitiveImportRidesTheHoist217` adds, to the materialized-import listing a
MODULE builds for each package it wildcard-imports, the CLONE that package's
OWN listing already carries for the packages IT wildcard-imports.  So a row can
move ONLY IF its database holds a package whose own listing is ENLARGED — i.e.
some OTHER package's complete ordered listing appears in it as a contiguous
sub-block.  That test is computable from OUR pristine database alone, because
`emitPackage` (`impVars9`) already emits the transitive clone at package scope;
it is an UPPER BOUND, and a database it calls CLEAN cannot move.

For every row it does NOT call clean, the row's OWN golden (read out of that
row's OWN `cmds.txt` — SeqDriver's two modes are different cache entries,
RESUME §9) is loaded and the module/interface listing gap is classified:

  TO-GOLDEN  golden's cell is LONGER than ours and the surplus is exactly a
             whole number of copies of an enlarged package's clone block
  AWAY       ours is longer than golden's, or the surplus is something else

usage: pred217.py <sweep workdir> <ct217net> [out.txt]
"""
import os
import subprocess
import sys
from collections import defaultdict


def census(cen, db):
    try:
        r = subprocess.run([cen, db, '--vars'], capture_output=True, text=True,
                           timeout=900)
    except subprocess.TimeoutExpired:
        return None
    if r.returncode != 0:
        return None
    cells = defaultdict(list)
    for line in r.stdout.splitlines():
        f = line.split('|')
        if f[0] == 'ARITY' and len(f) >= 6:
            cells.setdefault((f[1], f[2], f[3]), [])
        elif f[0] in ('NET', 'VAR') and len(f) >= 6:
            vec = 'nets' if f[0] == 'NET' else 'vars'
            cells[(f[1], f[2], vec)].append((int(f[3]), f[5]))
    out = {}
    for k, v in cells.items():
        v.sort()
        out[k] = [x[1] for x in v]
    return out


def pkg_listings(c):
    """package key -> its flat listing (nets then vars, as the DB records)."""
    out = {}
    for (view, key, vec), v in c.items():
        if view != 'pkg':
            continue
        out.setdefault(key, [[], []])
        out[key][0 if vec == 'nets' else 1] = v
    return {k: (v[0] + v[1]) for k, v in out.items() if (v[0] + v[1])}


def contiguous(hay, needle):
    n = len(needle)
    if n == 0 or n > len(hay):
        return -1
    for i in range(len(hay) - n + 1):
        if hay[i:i + n] == needle:
            return i
    return -1


def enlarged(pkgs):
    """package -> list of (other package, clone length) it carries whole.

    The test is deliberately LOOSE — a BAG subset, not just a contiguous
    sub-block — so that a clone split across a package's `Nets()` and
    `Variables()` vectors still fires.  It is an UPPER BOUND on purpose: a row
    it calls clean cannot move; a row it fires on may still not move.
    """
    from collections import Counter
    bags = {p: Counter(l) for p, l in pkgs.items()}
    out = {}
    for p, lp in pkgs.items():
        hits = []
        for q, lq in pkgs.items():
            if q == p or not lq or len(lq) > len(lp):
                continue
            if not (bags[q] - bags[p]):
                hits.append((q, len(lq), contiguous(lp, lq) >= 0))
        if hits:
            out[p] = hits
    return out


def main():
    if len(sys.argv) < 3:
        print('usage: pred217.py <sweep workdir> <ct217net> [out.txt]')
        return 2
    wd, cen = sys.argv[1], sys.argv[2]
    outp = sys.argv[3] if len(sys.argv) > 3 else None
    lines = []

    def say(s):
        lines.append(s)
        print(s, flush=True)

    scanned = fired = nogold = away = 0
    for mode in ('default', 'testflags'):
        base = os.path.join(wd, mode)
        if not os.path.isdir(base):
            continue
        for d in sorted(os.listdir(base)):
            dd = os.path.join(base, d)
            ours = os.path.join(dd, 'slang.uhdm')
            if not os.path.isfile(ours):
                continue
            scanned += 1
            co = census(cen, ours)
            if co is None:
                say('NOCENSUS %s %s' % (d, mode))
                continue
            pk = pkg_listings(co)
            en = enlarged(pk)
            if not en:
                continue
            # candidate: does the database have a module/interface at all?
            insts = [k for k in co
                     if k[0] in ('def', 'defif', 'elab') and
                     (k[1].startswith('module_inst') or
                      k[1].startswith('interface_inst') or
                      k[1].startswith('program'))]
            if not insts:
                continue
            cmds = os.path.join(dd, 'cmds.txt')
            gold = None
            if os.path.isfile(cmds):
                for l in open(cmds, 'rt', errors='replace'):
                    if 'golden cache hit' in l:
                        gold = l.split('golden cache hit ')[1].strip().rstrip(')')
                        gold = os.path.join(gold, 'golden.uhdm')
                    elif l.startswith('surelog:') and ' -o ' in l:
                        pass
            if not gold or not os.path.isfile(gold):
                nogold += 1
                say('CANDIDATE-NOGOLDEN %s %s enlarged=%s' %
                    (d, mode, ';'.join('%s+%d' % (q, n)
                                       for p, h in en.items() for q, n, _c in h)))
                fired += 1
                continue
            cg = census(cen, gold)
            if cg is None:
                nogold += 1
                say('CANDIDATE-NOGOLDCENSUS %s %s' % (d, mode))
                fired += 1
                continue
            clone_lens = sorted({n for h in en.values() for _, n, _c in h})
            tog = aw = 0
            det = []
            for k in sorted(set(co) | set(cg)):
                if k[0] not in ('def', 'defif', 'elab'):
                    continue
                if not (k[1].startswith('module_inst') or
                        k[1].startswith('interface_inst') or
                        k[1].startswith('program')):
                    continue
                lo, lg = co.get(k, []), cg.get(k, [])
                if len(lo) == len(lg):
                    continue
                gap = len(lg) - len(lo)
                fits = any(gap % n == 0 for n in clone_lens if n) and gap > 0
                det.append('%s|%s|%s G=%d O=%d gap=%+d %s' %
                           (k[0], k[1], k[2], len(lg), len(lo), gap,
                            'FITS-CLONE' if fits else 'OTHER'))
                if gap > 0:
                    tog += 1
                else:
                    aw += 1
            fired += 1
            if aw:
                away += 1
            say('FIRE %s %s enlarged=%s cells-TO-GOLDEN=%d cells-AWAY=%d' %
                (d, mode, ';'.join('%s<-%s+%d' % (p, q, n)
                                   for p, h in en.items() for q, n, _c in h),
                 tog, aw))
            for x in det:
                say('   %s' % x)
    say('-- rows scanned=%d  CANDIDATES (upper bound)=%d  no-golden=%d  '
        'rows with an OURS-LONGER cell=%d' % (scanned, fired, nogold, away))
    if outp:
        with open(outp, 'wt') as f:
            f.write('\n'.join(lines) + '\n')
    return 0


if __name__ == '__main__':
    sys.exit(main())
