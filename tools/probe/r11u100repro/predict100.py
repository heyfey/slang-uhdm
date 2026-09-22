#!/usr/bin/env python3
"""r11u100 A-PRIORI MOVER PREDICTION, BY ROW NAME — r11u96's `predict96.py`
re-keyed onto this pass's classes.

`census97.py` keys on the TEST DIRECTORY, which is the wrong grain for a
byteverify: one directory feeds several sweep rows under other names, and a
Surelog row's `.sl`/`.scr` names sources outside its own tree.  This reads the
SWEEP'S OWN workdir — one directory per row, each holding the `cmds.txt` that
row compiled — resolves every source the command names against the row's test
directory, ALSO walks that whole directory, and answers per row whether any
file it could have read carries a shape of any class.  The byteverify's mover
list must be a SUBSET of what this prints.

usage: predict97.py <sweep workdir> [<workdir> ...]
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
for sib in ('r11u97repro', 'r11u96repro', 'r11u94repro'):
    for cand in (os.path.join(HERE, '..', sib),
                 os.path.expanduser(
                     '~/git-repos/slang-uhdm/tools/probe/' + sib)):
        if os.path.isdir(cand):
            sys.path.insert(0, cand)
            break
import census100 as S                                           # noqa: E402

N = S.N
C = S.C
ROOTS = [os.path.expanduser(p) for p in
         ('~/git-repos/uhdm2rtlil/test', '~/git-repos/Surelog/tests',
          '~/git-repos/Surelog/third_party/tests')]
SRC = re.compile(r'(?<![\w=+])((?:\.\./|/|\w)[\w./+-]*\.(?:sv|svh|v|vh))')
CACHE = {}
DIRS = {}


def file_tags(p):
    rp = os.path.realpath(p)
    if rp in CACHE:
        return CACHE[rp]
    tg = set()
    try:
        t = C.strip_noise(open(rp, errors='replace').read())
        for nm, ty, init in N.decls94(t):
            tg |= S.tags100(nm, ty, init)
        for k in S.digitsrc100(t):
            tg.add(k)
    except OSError:
        pass
    CACHE[rp] = tg
    return tg


SLDIR = {}


def index_sl():
    """`verify_golden.py:440` keys a Surelog row on the `<name>.sl` FILE, and
    its directory is often named something else entirely."""
    if SLDIR:
        return
    for r in ROOTS[1:]:
        for dp, dn, fn in os.walk(r):
            dn[:] = [x for x in dn
                     if x not in ('.git', 'slpp_all', 'slpp_unit')]
            for f in fn:
                if f.endswith('.sl'):
                    SLDIR.setdefault(f[:-3], dp)


def testdir(base):
    if base in DIRS:
        return DIRS[base]
    d = None
    for r in ROOTS:
        q = os.path.join(r, base)
        if os.path.isdir(q):
            d = q
            break
    if d is None:
        index_sl()
        d = SLDIR.get(base)
    DIRS[base] = d
    return d


def main():
    rows, unresolved = {}, []
    for wd in sys.argv[1:]:
        for dp, dn, fn in os.walk(wd):
            if 'cmds.txt' not in fn:
                continue
            row = os.path.basename(dp)
            base = row.rsplit('-', 1)[0]
            d = testdir(base)
            if d is None:
                unresolved.append(row)
                continue
            tg = set()
            txt = open(os.path.join(dp, 'cmds.txt'), errors='replace').read()
            for m in SRC.finditer(txt):
                p = m.group(1)
                q = p if os.path.isabs(p) else os.path.normpath(
                    os.path.join(d, p))
                if os.path.isfile(q):
                    tg |= file_tags(q)
            for ddp, ddn, dfn in os.walk(d):
                ddn[:] = [x for x in ddn
                          if x not in ('.git', 'slpp_all', 'slpp_unit')]
                for f in dfn:
                    if f.endswith(C.EXTS):
                        tg |= file_tags(os.path.join(ddp, f))
            tg.discard('UARW100')
            tg.discard('POWW100')
            if tg:
                rows[base] = rows.get(base, set()) | tg
    # THE GATE.  `BARE100` alone is 3829 declarations corpus-wide — every
    # `localparam W = 4` is a bare decimal — and NONE of them can move: the
    # producer's digits and slang's store agree below 2**31.  A row can only
    # move where a SHAPE class meets a DIGIT SOURCE, except POW100, whose
    # const type moves at every magnitude.  Both readings are printed: the
    # gated one is the prediction the byteverify's mover list must be a
    # SUBSET of, the loose one is the honest superset behind it.
    # § powTopIsIntReduce100 is the ONLY face this patch ships ON, and its
    # class is POW100: the const type goes 9 -> 7 at every magnitude, so a row
    # moves iff it declares a package parameter with `**` at the top and reads
    # it through the package-parameter fold.  The OFF faces'
    # (§ uintArmWrittenDigitsMasked100 / § bareUnsizedDecIsMaskedDigits100)
    # class is printed too — SHAPE meeting DIGIT — because it is what the
    # prediction WOULD be when their flags are flipped, and because a census
    # class with no live law is still the honest superset of the code that is
    # compiled behind it.
    SHAPE = {'UAR100', 'BARE100', 'BNAM100'}
    DIGIT = {'UDC100', 'UNBO100', 'BWL100'}
    gated = {r: t for r, t in rows.items() if 'POW100' in t}
    offrows = {r: t for r, t in rows.items()
               if (t & SHAPE) and (t & DIGIT)}
    print('OFF-FACE candidates (flags false, must move NOTHING): %d rows'
          % len(offrows))
    for r in sorted(gated):
        print('%-46s %s' % (r, '+'.join(sorted(gated[r]))))
    print('PREDICTED MOVER CANDIDATES: %d rows  (loose class union: %d rows)'
          % (len(gated), len(rows)))
    if unresolved:
        print('UNRESOLVED test dirs: %d  %s'
              % (len(unresolved), ' '.join(sorted(set(unresolved))[:8])))


main()
