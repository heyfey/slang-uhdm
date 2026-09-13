#!/usr/bin/env python3
"""r11u7 — A-PRIORI mover prediction from the PRISTINE DATABASES.

  predictdb7.py <pristine-verify_golden-workdir> [name ...]

`predict7.py` narrows the corpus from its SOURCES alone (no interface, no
`'{`, no nesting -> the law cannot be reached).  This one reads the PRISTINE
databases themselves and applies the SHAPE half of the applier's gate:

  a database can move only if it holds a non-def `interface_inst` view whose
  param_assign Rhs is an `op75` AND whose DEF-view counterpart for the same
  parameter is an `op75` whose FIRST operand is a `tagged_pattern` wrapping
  another `op75` (the nested-aggregate first member the gate requires).

IT IS A SUPERSET, AND THIS SAYS SO OUT LOUD.  A dump does not say which view
is a HOME view (reached through the override path, not this law) and does not
say whether a port view was reached by a NAMED MODPORT connection --
`namedModportPortView9` keeps the whole r11u4 port-view block, and therefore
this law, off that cell.  Measured: it names 6 u2r tests, and byteverify
measures ZERO u2r movers, because every one of those connections is
`.s(s.sub)` -- a named modport -- and the sibling row it also names is the
home view.  What the tool is FOR is the other direction: every ACTUAL mover
must appear here, and a mover outside it would convict the model.

Prints one line per test/mode: `MOVE` or `no`, and the views it would touch.
"""
import os, re, subprocess, sys

DUMP = os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump')
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import pacen7  # noqa: E402


def viewrows(dumppath):
    out = subprocess.run([sys.executable,
                          os.path.join(HERE, 'pacen7.py'), dumppath],
                         capture_output=True, text=True)
    rows = {}
    for ln in out.stdout.splitlines():
        m = re.match(r'(\S+)\s+(\S+)\s+(ovr=\d.*)$', ln)
        if m:
            rows[(m.group(1), m.group(2))] = m.group(3)
    return rows


# the def view's Rhs shape the gate requires: op75 whose FIRST operand is a
# tagged_pattern whose pattern is itself an op75
NESTED = re.compile(r'^ovr=\d op75\[ts=-\]\(tagged\[[^]]*\]\(op75')


def predict(dumppath):
    rows = viewrows(dumppath)
    defs = {p: s for (v, p), s in rows.items() if '.' not in v.split('@')[-1]}
    hits = []
    for (v, p), s in sorted(rows.items()):
        if '.' not in v.split('@')[-1]:
            continue
        d = defs.get(p)
        if not d or not NESTED.match(d):
            continue
        if 'op75' not in s:
            continue
        if s == d:
            continue           # already the def tree
        hits.append((v, p))
    return hits


def main(a):
    wd = a[0]
    want = set(a[1:])
    for mode in ('default', 'testflags'):
        root = os.path.join(wd, mode)
        if not os.path.isdir(root):
            continue
        for d in sorted(os.listdir(root)):
            name = d.rsplit('-', 1)[0]
            if want and name not in want:
                continue
            db = os.path.join(root, d, 'slang.uhdm')
            if not os.path.isfile(db):
                print('%-44s %-9s NO-DATABASE' % (name, mode))
                continue
            dp = '/tmp/r11u7_predictdb.dump'
            with open(dp, 'wb') as fh:
                subprocess.run([DUMP, db], stdout=fh,
                               stderr=subprocess.DEVNULL)
            hits = predict(dp)
            print('%-44s %-9s %s %s' % (
                name, mode, 'MOVE' if hits else 'no',
                ' '.join('%s/%s' % h for h in hits)))


if __name__ == '__main__':
    main(sys.argv[1:])
