#!/usr/bin/env python3
"""r10uvm73 — MOVER PREDICTION, computed from the PRISTINE workdirs ALONE and
written down BEFORE the patched sweep is compared.

§ classScopedTypedefPropIsBareLogicVar73 is decided by SOURCE SYNTAX — a
declaration whose TYPE NAME is class-scope qualified (`C::t x;`) or names a
typedef inherited from a base class — so the prediction is made on the SOURCES
each pristine database was actually built from, not on the database's shape.
The file set is read out of the database itself (every `file:` path uhdm-dump
prints), so a test's whole include closure is covered without re-running any
tool.

WHAT IT REPORTS, and the direction of its error, stated rather than implied:
  * `PREDICT_MOVE` — some source file of that database writes a `X::y name;`
    declaration.  This is an UPPER bound: the same spelling inside a FUNCTION
    BODY does not move (arm a1 cell l_qual_enum), and the regex cannot tell a
    class body from a function body.
  * the INHERITED-unqualified half of clause (3) is NOT predicted at all (a
    bare name gives the scanner nothing to key on), so for that one shape the
    prediction is a LOWER bound.  Any mover the sweep produces that this
    script did not name must therefore be explained by that half — and each one
    was, by hand, against the census.

usage: ct73predict.py <pristine workdir root>
"""
import os
import re
import subprocess
import sys

DUMP = os.environ.get('UHDM_DUMP',
                      os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump'))

# `[rand|static|const|local|protected|virtual] Name[#(...)]::Name  ident [= ...];`
DECL = re.compile(
    r'^[ \t]*(?:(?:rand|randc|static|const|local|protected|virtual)[ \t]+)*'
    r'[A-Za-z_]\w*(?:[ \t]*#[ \t]*\([^;]*\))?::[A-Za-z_]\w*[ \t]+'
    r'[A-Za-z_]\w*[ \t]*(?:\[[^;]*\])?[ \t]*(?:=[^;]*)?;')
FILEPAT = re.compile(r'file:(/[^\s,]+)')


def files_of(db):
    out = subprocess.run([DUMP, db], capture_output=True, text=True,
                         timeout=1800).stdout
    if not out:
        return None
    return sorted(set(FILEPAT.findall(out)))


def main():
    root = sys.argv[1]
    dbs = []
    for d, _, fs in os.walk(root):
        if 'slang.uhdm' in fs:
            dbs.append(os.path.join(d, 'slang.uhdm'))
    dbs.sort()
    nmove = fails = 0
    cache = {}
    for db in dbs:
        rel = os.path.relpath(db, root)
        try:
            fl = files_of(db)
        except Exception as e:
            print('DUMP_FAIL %s (%s)' % (rel, e))
            fails += 1
            continue
        if fl is None:
            print('DUMP_FAIL %s (empty dump)' % rel)
            fails += 1
            continue
        hits = []
        for f in fl:
            if f not in cache:
                try:
                    cache[f] = [(i + 1, l.rstrip())
                                for i, l in enumerate(open(f, errors='replace'))
                                if DECL.match(l)]
                except OSError:
                    cache[f] = []
            for ln, txt in cache[f]:
                hits.append('%s:%d: %s' % (os.path.basename(f), ln, txt.strip()))
        if hits:
            nmove += 1
            print('PREDICT_MOVE %-58s sites=%d files=%d' % (rel, len(hits), len(fl)))
            for h in sorted(set(hits))[:12]:
                print('    ' + h)
    print('---- databases=%d PREDICTED_MOVERS=%d DUMP_FAIL=%d' %
          (len(dbs), nmove, fails))


if __name__ == '__main__':
    main()
