#!/usr/bin/env python3
# r10v215 — THE WHOLE-DUMP REGRESSION SCORER.  MEASUREMENT ONLY; the official
# uhdm-cmp is the sole acceptance judge.  This tool answers ONE question the
# implementer's modport-only census cannot: did the patch take away a dump line
# that golden HAS and the PRISTINE binary already produced?  A modport-keyed
# census is blind to a LowConn ref_obj that stopped binding, to a port that lost
# its Actual_group, to a typespec that changed name — all of which sit on the
# roads § modportNeedsSimplePort215 touches.
#
# LHS is ALWAYS golden.  Scored as MULTISETS of normalised uhdm-dump lines:
#   ONLY-GOLDEN(x) = multiset(golden) - multiset(x)
#   ONLY-OURS(x)   = multiset(x) - multiset(golden)
# REGRESS = ONLY-GOLDEN(patched) - ONLY-GOLDEN(pristine)   (golden lines the
#           pristine binary produced and the patched one no longer does)
# FIXES   = ONLY-GOLDEN(pristine) - ONLY-GOLDEN(patched)
# NEWJUNK = ONLY-OURS(patched)   - ONLY-OURS(pristine)
# DROPJUNK= ONLY-OURS(pristine)  - ONLY-OURS(patched)
# A pass is clean on an arm iff REGRESS and NEWJUNK are both EMPTY.
#
# Normalisation strips only what is not comparable across producers: the
# `Restored design` banner, object ids, and absolute directories (the dump path
# embeds the workdir — RESUME §9).  Indentation is KEPT (it encodes tree depth).
# usage: dumpcen215v.py <golden.dump> <pristine.dump> <patched.dump>
import re
import sys
from collections import Counter

ID = re.compile(r'id:\d+')
DIR = re.compile(r'/[^ ,:)\t]*/')


def load(p):
    out = []
    with open(p, errors='replace') as f:
        for i, ln in enumerate(f):
            ln = ln.rstrip('\n')
            if i == 0 and 'Restored design' in ln:
                continue
            ln = ID.sub('id:N', ln)
            ln = DIR.sub('/D/', ln)
            out.append(ln)
    return Counter(out)


def main():
    g, p, q = (load(a) for a in sys.argv[1:4])
    og_p, og_q = g - p, g - q
    oo_p, oo_q = p - g, q - g
    # SIGNED distance per line.  A raw multiset difference is direction-blind:
    # a line the pristine binary OVER-produced (14 copies against golden's 11)
    # and the patched one now produces 10 times shows up as "a lost golden
    # line" though the patch moved it CLOSER.  AWAY/TOWARD compare |ours-golden|
    # before and after, which is the only honest reading for the structural
    # lines (`|vpiActual:`, `|vpiInterface:`) that recur all over a dump.
    away, toward = Counter(), Counter()
    for ln in set(g) | set(p) | set(q):
        dp = abs(p[ln] - g[ln])
        dq = abs(q[ln] - g[ln])
        if dq > dp:
            away[ln] = dq - dp
        elif dq < dp:
            toward[ln] = dp - dq
    for tag, c in (('AWAY', away), ('TOWARD', toward)):
        for ln, n in sorted(c.items()):
            print('%s %d %s' % (tag, n, ln.strip()))
    print('TOTALS onlyG_pris=%d onlyG_pat=%d onlyO_pris=%d onlyO_pat=%d '
          'AWAY=%d TOWARD=%d' %
          (sum(og_p.values()), sum(og_q.values()), sum(oo_p.values()),
           sum(oo_q.values()), sum(away.values()), sum(toward.values())))


main()
