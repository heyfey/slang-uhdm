#!/usr/bin/env python3
"""r10uvm71 -- PREDICT THE MOVERS, from the PRISTINE workdir, BEFORE the
patched sweep runs.

  usage: ct71predict.py <pristine_workdir_root>

`§ ctorBodyLocalsNotOnFunc71` removes the vpiVariables vector from CLASS
CONSTRUCTORS and touches nothing else.  A database therefore moves if and only
if, in the PRISTINE build, at least one of its constructors carries that vector.
That is a property of the pristine workdir alone, so the mover set can be named
BEFORE the patched sweep exists -- which is the point: a mover list produced
after the fact predicts nothing.

Prints one line per database that is predicted to MOVE, with the constructors
and the variable count that will disappear, then the totals.

TRAPS: `sed 1d` on the dump (its first line is the database path); a childless
print is a BACK-REFERENCE and carries no fields; objects merged by
(kind, fullname, span).  A database that fails to dump is reported as
DUMP_FAIL and COUNTED -- a predictor that silently skips inputs would under-
predict and then congratulate itself when the sweep agreed.
"""
import collections
import os
import subprocess
import sys

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from dumptree import parse, is_backref   # noqa: E402

UHDM_DUMP = os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump')
SUBS = ('function', 'task')

root = sys.argv[1]
paths = []
for dirpath, _d, files in os.walk(root):
    if 'slang.uhdm' in files:
        paths.append(os.path.join(dirpath, 'slang.uhdm'))
paths.sort()
print('databases scanned: %d' % len(paths), file=sys.stderr)

movers = []
fails = 0
tmp = '/tmp/r10uvm71_predict.dump'
for i, p in enumerate(paths, 1):
    rel = os.path.relpath(p, root)
    try:
        with open(tmp, 'wb') as fh:
            r = subprocess.run([UHDM_DUMP, p], stdout=fh,
                               stderr=subprocess.DEVNULL, timeout=600)
        if r.returncode != 0:
            print('DUMP_FAIL %s' % rel)
            fails += 1
            continue
    except Exception as exc:
        print('DUMP_FAIL %s (%s)' % (rel, exc))
        fails += 1
        continue
    # drop the database-path first line exactly as every other instrument does
    with open(tmp, 'rt', errors='replace') as fh:
        lines = fh.readlines()[1:]
    with open(tmp + '.2', 'wt') as fh:
        fh.writelines(lines)
    _roots, nodes = parse(tmp + '.2')
    merged = collections.OrderedDict()
    for n in nodes:
        if n.kind not in SUBS or is_backref(n):
            continue
        merged.setdefault((n.kind, n.name, n.span), n)
    hits = []
    for (_k, nm, sp), n in merged.items():
        if not nm.endswith('::new'):
            continue
        nv = sum(1 for f, _kid in n.children if f == 'vpiVariables')
        if nv:
            hits.append((nm, sp, nv))
    if hits:
        movers.append((rel, hits))
        print('PREDICT_MOVER %s  ctors=%d vars=%d  %s'
              % (rel, len(hits), sum(h[2] for h in hits),
                 ';'.join('%s@%s(%d)' % h for h in hits)))
    if i % 100 == 0:
        print('  %d/%d' % (i, len(paths)), file=sys.stderr)

print('-- databases scanned:  %d' % len(paths))
print('-- PREDICTED MOVERS:   %d' % len(movers))
print('-- DUMP_FAIL:          %d' % fails)
