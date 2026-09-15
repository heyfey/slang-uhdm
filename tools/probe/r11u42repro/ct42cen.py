#!/usr/bin/env python3
"""r11u42 CENSUS — § hpTrailSelPkgFold42's A-PRIORI mover predictor, and the
SHAPE LISTER that must sit beside it.

Reads a set of UHDM databases (a sweep workdir root, or the golden cache dirs
those workdirs name) and, per database, reports every `hier_path` whose
`VpiName` carries a bracket group whose text still mentions a PACKAGE-scope
parameter by IDENTIFIER.  Those are exactly the cells § hpTrailSelPkgFold42 can
reach, so:

  * run over OUR PRISTINE databases it PREDICTS the movers BY NAME, before the
    patched binary has been built;
  * run over GOLDEN it is the calibration: golden folds the package leaf, so a
    golden cell that still spells one is a cell golden does NOT fold (the
    concat/replication-initialised parameters of § hpMixedIdxPkgFold34's V-F1
    gate, and any module-scope name that happens to share a package name).

Package parameters are recognised from the dump's own labels: a `\\_parameter:`
whose parenthesised fullname is `<pkg>::<NAME>` with no `@` and no `.` in the
prefix is package-scope; `work@mod.NAME` is not.

Usage:
  ct42cen.py --roots <dir> [<dir> ...] [--label L] [--jobs N] [--dump PATH]
     each <dir> is searched for `slang.uhdm` (ours) / `golden.uhdm` (golden).
Output: one CAND / NOCAND line per database, then a SHAPE histogram and totals.
"""
import argparse
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

PARAM_RE = re.compile(r'\\_parameter: \(([A-Za-z_$][\w$]*)::([A-Za-z_$][\w$]*)\)')
HP_RE = re.compile(r'\\_hier_path: \(([^)]*)\)')
IDENT_RE = re.compile(r'[A-Za-z_$][\w$]*(?:::[A-Za-z_$][\w$]*)*')


def bracket_groups(name):
    """Every TOP-LEVEL bracket group's inner text, in order."""
    out, depth, start = [], 0, None
    for i, c in enumerate(name):
        if c == '[':
            if depth == 0:
                start = i + 1
            depth += 1
        elif c == ']':
            depth -= 1
            if depth == 0 and start is not None:
                out.append(name[start:i])
                start = None
    return out


def shape_of(name):
    """The SHAPE LISTER key: how many dotted components, where the brackets are."""
    comps = name.split('.')
    braq = [('[' in c) for c in comps]
    if len(comps) == 1:
        return 'bare' + ('[]' if braq[0] else '')
    if any(braq[:-1]):
        return 'dotted%d/base-or-mid-sel' % len(comps)
    return 'dotted%d/%s' % (len(comps), 'trail-sel' if braq[-1] else 'no-sel')


def one(path, dump):
    try:
        r = subprocess.run([dump, path], capture_output=True, text=True,
                           timeout=900)
    except subprocess.TimeoutExpired:
        return (path, 'DUMP_TIMEOUT', [], {})
    if r.returncode != 0:
        return (path, 'DUMP_RC%d' % r.returncode, [], {})
    txt = r.stdout
    pkg = set()
    for m in PARAM_RE.finditer(txt):
        pkg.add(m.group(2))
        pkg.add(m.group(1) + '::' + m.group(2))
    cells, shapes = [], {}
    seen = set()
    for m in HP_RE.finditer(txt):
        nm = m.group(1)
        if nm in seen:
            continue
        seen.add(nm)
        sh = shape_of(nm)
        shapes[sh] = shapes.get(sh, 0) + 1
        hit = False
        for g in bracket_groups(nm):
            for t in IDENT_RE.findall(g):
                if t in pkg or t.split('::')[-1] in pkg:
                    hit = True
        if hit:
            cells.append(nm)
    return (path, 'OK', cells, shapes)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--roots', nargs='+', required=True)
    ap.add_argument('--label', default='census')
    ap.add_argument('--jobs', type=int, default=2)
    ap.add_argument('--dump',
                    default=os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump'))
    a = ap.parse_args()
    paths = []
    for root in a.roots:
        for dp, _dn, fn in os.walk(root, followlinks=True):
            for f in fn:
                if f in ('slang.uhdm', 'golden.uhdm'):
                    paths.append(os.path.join(dp, f))
    paths.sort()
    print('LABEL %s  databases=%d' % (a.label, len(paths)))
    if not paths:
        print('NO_DATABASES — a zero here means nothing')
        return 2
    shapes_all, ncand, ncells, bad = {}, 0, 0, 0
    with ThreadPoolExecutor(max_workers=a.jobs) as ex:
        for p, st, cells, shapes in ex.map(lambda q: one(q, a.dump), paths):
            for k, v in shapes.items():
                shapes_all[k] = shapes_all.get(k, 0) + v
            if st != 'OK':
                bad += 1
                print('BAD %s %s' % (st, p))
                continue
            if cells:
                ncand += 1
                ncells += len(cells)
                print('CAND %s :: %s' % (p, ' | '.join(sorted(cells))))
            else:
                print('NOCAND %s' % p)
    print('SHAPES (the shape lister, distinct hier_path names):')
    for k in sorted(shapes_all):
        print('  %-28s %d' % (k, shapes_all[k]))
    print('TOTAL databases=%d CAND=%d NOCAND=%d BAD=%d CELLS=%d'
          % (len(paths), ncand, len(paths) - ncand - bad, bad, ncells))
    return 0


if __name__ == '__main__':
    sys.exit(main())
