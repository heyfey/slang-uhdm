#!/usr/bin/env python3
# r10uvm119repro/score119.py — TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG / UNTOUCHED
# / EQUAL-BOTH, per cell, over the pristine and patched censuses.  MEASUREMENT
# ONLY.
#
#   score119.py <cen-dir-pristine> <cen-dir-patched>
#
# ASSERTS FIRST that the GOLDEN side of every cell is byte-identical in the two
# runs: a scorer that does not re-read golden cannot tell a golden change from
# a mover, and refuses rather than reporting.
#
# The join is a MULTISET join on (FORM, KEY) — keys collide (the DEF and ELAB
# views emit the same site twice) and a last-writer dict would silently drop
# half the population.  Because this pass REMOVES text from a name, cells can
# be ONE-SIDED in either run (uvm109's rule), so the value compared is the
# SORTED MULTISET of descriptions on each side and a missing side is scored
# explicitly rather than skipped.
#
# TWO SCORES ARE PRINTED, and the difference between them is itself a
# measurement:
#   STRICT       — the census exactly as read, constraints keyed on the dump's
#                  SYNTHESISED fullname (a PARENT-CHAIN reading).
#   PARENT-BLIND — every constraint's synthesised fullname replaced by a
#                  placeholder, so constraints are scored by EXISTENCE and by
#                  WHICH CALL HOLDS THEM, never by their parent.  This is the
#                  JUDGE'S view: `constraint::Compare`
#                  (UHDM/build/generated/src/constraint.cpp:133) reads VpiName,
#                  VpiVirtual, VpiAutomatic, VpiAllocScheme, VpiAccessType,
#                  Attributes, VpiIsConstraintEnabled and Constraint_items, and
#                  NO generated Compare reads VpiParent at all (RESUME §9).
import sys, os, re, collections

CONSFN = re.compile(r'constraint\(([^)]*)\)')

def load(p, blind=False):
    m = collections.defaultdict(collections.Counter)
    for line in open(p):
        f = line.rstrip('\n').split('\t')
        if len(f) < 4:
            continue
        form, k, v = f[0], f[2], f[3]
        if blind:
            v = CONSFN.sub('constraint(<parent-synthesised>)', v)
            if form == 'CONS':
                k = '<parent-synthesised>@' + k.split('@', 1)[1]
        m[(form, k)][v] += 1
    return m

def sig(c):
    return tuple(sorted(c.items())) if c else ()

A, B = sys.argv[1], sys.argv[2]
cells = sorted({f.split('.', 2)[2].rsplit('.txt', 1)[0]
                for f in os.listdir(A) if f.startswith('cen.g.')})
bad = 0
for c in cells:
    if not os.path.exists('%s/cen.g.%s.txt' % (B, c)):
        print('FATAL: patched run has no golden census for %s' % c); bad += 1; continue
    if open('%s/cen.g.%s.txt' % (A, c)).read() != open('%s/cen.g.%s.txt' % (B, c)).read():
        print('FATAL: GOLDEN CHANGED between the runs for %s' % c); bad += 1
if bad:
    sys.exit('refusing to score')
print('GOLDEN-SIDE CALIBRATION: identical in both runs for all %d cells' % len(cells))
print()
for BLIND in (False, True):
  print('---- %s ----' % ('PARENT-BLIND (the judge\'s view)' if BLIND else 'STRICT (dump fidelity)'))
  tot = collections.Counter()
  for c in cells:
    G  = load('%s/cen.g.%s.txt' % (A, c), BLIND)
    O1 = load('%s/cen.o.%s.txt' % (A, c), BLIND)
    O2 = load('%s/cen.o.%s.txt' % (B, c), BLIND)
    r = collections.Counter()
    for k in sorted(set(G) | set(O1) | set(O2)):
        g, o1, o2 = sig(G.get(k)), sig(O1.get(k)), sig(O2.get(k))
        if o1 == o2:
            r['EQUAL-BOTH' if o1 == g else 'UNTOUCHED'] += 1
        elif o2 == g:
            r['TO-GOLDEN'] += 1
        elif o1 == g:
            r['AWAY-GOLDEN'] += 1
        else:
            r['STILL-WRONG'] += 1
    print('%-26s TO-GOLDEN=%-4d AWAY-GOLDEN=%-3d STILL-WRONG=%-3d UNTOUCHED=%-4d EQUAL-BOTH=%d'
          % (c, r['TO-GOLDEN'], r['AWAY-GOLDEN'], r['STILL-WRONG'], r['UNTOUCHED'], r['EQUAL-BOTH']))
    for k in r: tot[k] += r[k]
  print()
  print('TOTAL  TO-GOLDEN=%d  AWAY-GOLDEN=%d  STILL-WRONG=%d  UNTOUCHED=%d  EQUAL-BOTH=%d'
        % (tot['TO-GOLDEN'], tot['AWAY-GOLDEN'], tot['STILL-WRONG'], tot['UNTOUCHED'], tot['EQUAL-BOTH']))
  print()
