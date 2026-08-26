#!/usr/bin/env python3
"""r10uvm159 — SCORE THE LAW over a ct159cls census dump.

MEASUREMENT ONLY (uhdm-cmp is the judge).  Reads the `--list` output of
cls159.sh / ct159cls and reports, for the law's population and for every other
population in the same census:

    WRONG->RIGHT   golden has the typespec, we now do too
    MOVED-WRONG    we have one where golden has a DIFFERENT one
    AWAY           we have one where golden's reachable object has NONE
    STILL-WRONG    golden has one, we still do not

The law's population is `own=operation ctx=tf home=cls` — a folded read of a
package parameter, owned by an OPERATION, inside a task/function whose home is
a CLASS.  Cells whose GOLDEN side has no reachable constant are excluded by
ct159cls itself (NO-GOLDEN-OBJ): golden kept a `ref_obj` there and left the
reduced value in the weaklyReferenced tail, so a stamp is neither toward nor
away from it (RESUME.md §9 — never count tail stamps).

    usage: score159.py <pristine.cls> [<patched.cls>] [--sel=own=...]
"""
import re, sys, collections

SEL = 'own=operation ctx=tf home=cls'


def tally(path):
    out = collections.Counter()
    dbs = collections.defaultdict(int)
    for line in open(path, errors='replace'):
        m = re.match(r'^(\S+) TALLY (MISSING-OURS|EXTRA-OURS) (own=\S+ ctx=\S+ home=\S+) n=(\d+)',
                     line)
        if not m:
            continue
        db, cls, key, n = m.group(1), m.group(2), m.group(3), int(m.group(4))
        out[(cls, key)] += n
        if key == SEL:
            dbs[(db, cls)] += n
    return out, dbs


def show(name, t, dbs):
    print('== %s' % name)
    sel_missing = t[('MISSING-OURS', SEL)]
    sel_extra = t[('EXTRA-OURS', SEL)]
    print('   LAW POPULATION  %s' % SEL)
    print('     STILL-WRONG (golden has ts, we do not) = %d' % sel_missing)
    print('     AWAY        (we have ts, golden none)  = %d' % sel_extra)
    for (db, cls), n in sorted(dbs.items()):
        print('       %-40s %-12s n=%d' % (db, cls, n))
    print('   EVERY OTHER POPULATION (must not move):')
    for (cls, key), n in sorted(t.items()):
        if key == SEL:
            continue
        print('     %-12s %-46s n=%d' % (cls, key, n))


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    tp, dp = tally(args[0])
    show('PRISTINE ' + args[0], tp, dp)
    if len(args) > 1:
        tq, dq = tally(args[1])
        show('PATCHED  ' + args[1], tq, dq)
        print('== DELTA (patched - pristine)')
        keys = set(tp) | set(tq)
        for k in sorted(keys):
            d = tq[k] - tp[k]
            if d:
                print('     %-12s %-46s %+d' % (k[0], k[1], d))
        print('   WRONG->RIGHT on the law population = %d' %
              (tp[('MISSING-OURS', SEL)] - tq[('MISSING-OURS', SEL)]))
        print('   AWAY introduced on the law population = %d' %
              (tq[('EXTRA-OURS', SEL)] - tp[('EXTRA-OURS', SEL)]))


main()
