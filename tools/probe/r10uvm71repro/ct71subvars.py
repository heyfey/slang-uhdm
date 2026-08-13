#!/usr/bin/env python3
"""r10uvm71 -- DOES A SUBROUTINE EVER CARRY vpiVariables?  One side per run.

  usage: ct71subvars.py <dump> [--list] [--stmt]

THE HEAD'S SHAPE, decoded by ct71fields.py: golden's
`function (uvm_pkg::uvm_objection::new)` has NO vpiVariables vector; ours has
three, and all three are ALSO on the body `begin` block, which is identical on
both sides.  `SafeCompare`'s vector form then fires with the CONTAINER as the
reported RHS.

This census asks the membership question design-wide and by SHAPE, so the law is
not read off one cell:

    for every FULL print of a function/task, does it have vpiVariables?
    if so, how many, and does its body statement ALSO carry them?

The `--stmt` column is the load-bearing one: a subroutine whose vpiStmt is a
`begin` that already lists the same variables is DOUBLE-BOOKING them.

TRAPS: `sed 1d` dumps; a childless print is a BACK-REFERENCE with no fields and
must not be counted as a variable-less subroutine.  Objects are merged by
(kind, fullname, span) so several full prints of one subroutine count once, and
a disagreement between those prints is REPORTED rather than silently reduced.
"""
import collections
import sys

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from dumptree import parse, is_backref   # noqa: E402

SUBS = ('function', 'task')


def varnames(n):
    return tuple(sorted('%s|%s|%s' % (k.kind, k.name, k.span)
                        for f, k in n.children if f == 'vpiVariables'))


def main():
    path = sys.argv[1]
    do_list = '--list' in sys.argv
    tsv = '--tsv' in sys.argv
    _roots, nodes = parse(path)

    merged = collections.OrderedDict()
    for n in nodes:
        if n.kind not in SUBS or is_backref(n):
            continue
        merged.setdefault((n.kind, n.name, n.span), []).append(n)

    withv = 0
    dbl = 0
    disagree = 0
    hist = collections.Counter()
    for key, prints in merged.items():
        vs = {varnames(p) for p in prints}
        if len(vs) > 1:
            disagree += 1
            print('SUBR_DISAGREE %s(%s)@%s across %d prints' %
                  (key[0], key[1], key[2], len(prints)))
        v = varnames(prints[0])
        if tsv:
            # ONE LINE PER SUBROUTINE, including the zero-variable ones, so a
            # plain `diff` of two sides names the disagreeing subroutines
            # instead of leaving a count delta to be guessed at.
            print('%s\t%s\t%s\t%d\t%s' % (key[0], key[1], key[2], len(v),
                                          ','.join(v)))
        if not v:
            continue
        withv += 1
        hist[len(v)] += 1
        # does the body statement also carry them?
        body = [k for f, k in prints[0].children if f == 'vpiStmt']
        bv = varnames(body[0]) if body else ()
        shared = set(v) & set(bv)
        if shared:
            dbl += 1
        if do_list:
            print('SUBR %-8s %-58s @%-18s nvars=%-3d bodyvars=%-3d shared=%d' %
                  (key[0], key[1], key[2], len(v), len(bv), len(shared)))

    print('-- subroutine OBJECTS (full prints merged): %d' % len(merged))
    print('-- with vpiVariables:                       %d' % withv)
    print('--   of those, ALSO on their body stmt:     %d' % dbl)
    print('-- SUBR_DISAGREE: %d' % disagree)
    print('-- vpiVariables count histogram: %s'
          % dict(sorted(hist.items())))


if __name__ == '__main__':
    main()
