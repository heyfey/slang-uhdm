#!/usr/bin/env python3
# r10vearl110 INDEPENDENT three-way scorer. Written from scratch by the VERIFIER;
# it does not share code with the implementer's score110.py.
# Key = the cen110 key column (span | ordered element kind:name vector).
# Value = the SET of hier_path VpiNames at that key (never the multiplicity:
# an elaborated copy count and a definition copy count differ legitimately).
# Verdicts, LHS is ALWAYS golden:
#   SAME_AGREE  pristine == golden and patched == golden
#   TOGOLD      pristine != golden and patched == golden          (a WIN)
#   AWAY        pristine == golden and patched != golden          (a REGRESSION)
#   MOVEDWRONG  pristine != patched, both != golden               (inspect)
#   STILLWRONG  pristine == patched != golden                     (untouched defect)
import sys, collections

def load(p):
    d = collections.defaultdict(set)
    with open(p, encoding='utf-8', errors='replace') as f:
        for ln in f:
            if ln.startswith('CENRC'):
                continue
            ln = ln.rstrip('\n')
            if '\t' not in ln:
                continue
            k, v = ln.split('\t', 1)
            # cen110 emits "<key>\t<name>\t<count>"; the NAME SET is the verdict,
            # the count is reported separately (an elaborated copy count and a
            # definition copy count differ legitimately -- r10uvm170 R6).
            parts = v.rsplit('\t', 1)
            nm = parts[0]
            d[k].add(nm)
    return d

g, p, a = (load(x) for x in sys.argv[1:4])
tag = sys.argv[4]
tal = collections.Counter()
rows = []
for k in sorted(set(g) | set(p) | set(a)):
    G, P, A = g.get(k), p.get(k), a.get(k)
    if G is None or P is None or A is None:
        # one-sided: report, never score as a win or a loss
        tal['ONESIDED'] += 1
        rows.append(('ONESIDED', k, G, P, A))
        continue
    if P == G and A == G:
        tal['SAME_AGREE'] += 1
    elif P != G and A == G:
        tal['TOGOLD'] += 1; rows.append(('TOGOLD', k, G, P, A))
    elif P == G and A != G:
        tal['AWAY'] += 1; rows.append(('AWAY', k, G, P, A))
    elif P == A:
        tal['STILLWRONG'] += 1; rows.append(('STILLWRONG', k, G, P, A))
    else:
        tal['MOVEDWRONG'] += 1; rows.append(('MOVEDWRONG', k, G, P, A))
for v, k, G, P, A in rows:
    if v == 'SAME_AGREE':
        continue
    print('  %-11s %s' % (v, k))
    print('      G %s' % (sorted(G) if G else None))
    print('      P %s' % (sorted(P) if P else None))
    print('      A %s' % (sorted(A) if A else None))
print('  TALLY[%s] SAME_AGREE=%d TOGOLD=%d AWAY=%d MOVEDWRONG=%d STILLWRONG=%d ONESIDED=%d' % (
    tag, tal['SAME_AGREE'], tal['TOGOLD'], tal['AWAY'], tal['MOVEDWRONG'],
    tal['STILLWRONG'], tal['ONESIDED']))
