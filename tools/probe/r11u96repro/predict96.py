#!/usr/bin/env python3
"""r11u96 A-PRIORI MOVER PREDICTION, BY ROW NAME — r11u94's `predict94.py`
re-keyed onto this pass's classes.

`census96.py` keys on the TEST DIRECTORY, which is the wrong grain for a
byteverify: one directory feeds several sweep rows under other names, and a
Surelog row's `.sl`/`.scr` names sources outside its own tree.  This reads the
SWEEP'S OWN workdir — one directory per row, each holding the `cmds.txt` that
row compiled — resolves every source the command names against the row's test
directory, ALSO walks that whole directory, and answers per row whether any
file it could have read carries a shape of any class.  The byteverify's mover
list must be a SUBSET of what this prints.

usage: predict96.py <sweep workdir> [<workdir> ...]
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
for sib in ('r11u94repro',):
    for cand in (os.path.join(HERE, '..', sib),
                 os.path.expanduser(
                     '~/git-repos/slang-uhdm/tools/probe/' + sib)):
        if os.path.isdir(cand):
            sys.path.insert(0, cand)
            break
import census96 as S                                           # noqa: E402

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
            tg |= S.tags96(nm, ty, init)
        if S.bigdec96(t, 31):
            tg.add('UDC96')
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
            tg.discard('MDMW96')
            tg.discard('UDC96W')
            if tg:
                rows[base] = rows.get(base, set()) | tg
    for r in sorted(rows):
        print('%-46s %s' % (r, '+'.join(sorted(rows[r]))))
    print('PREDICTED MOVER CANDIDATES: %d rows' % len(rows))
    if unresolved:
        print('UNRESOLVED test dirs: %d  %s'
              % (len(unresolved), ' '.join(sorted(set(unresolved))[:8])))


main()
