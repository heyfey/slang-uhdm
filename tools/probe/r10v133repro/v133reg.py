#!/usr/bin/env python3
"""r10v133 (VERIFIER) — REGRESSION detector, order-blind and cell-free.

Takes the three uhdm-dumps of one arm view and reports, as MULTISETS of
indent-stripped dump lines:

  LOST   a line golden HAS and pristine HAD, that patched no longer produces
  GAINED a line golden does NOT have, that pristine did not produce either,
         that patched now produces
  FIXED  a golden line pristine lacked and patched now produces
  REMOVED a non-golden line pristine produced and patched no longer does

LOST + GAINED are the ONLY regression evidence; FIXED + REMOVED are progress.
usage: v133reg.py <g.dump> <pris.dump> <pat.dump> [tag]
"""
import sys, collections


def ms(p):
    c = collections.Counter()
    for l in open(p, encoding='utf-8', errors='replace'):
        c[l.strip()] += 1
    return c


g, p, q = (ms(a) for a in sys.argv[1:4])
tag = sys.argv[4] if len(sys.argv) > 4 else ''
# golden lines each side supplies (capped at golden's own multiplicity)
gp = g & p
gq = g & q
lost = gp - gq            # golden coverage pristine had and patched lost
fixed = gq - gp
xp = p - g                # pristine's non-golden surplus
xq = q - g
gained = xq - xp
removed = xp - xq
print(f'{tag}\tLOST={sum(lost.values())} GAINED={sum(gained.values())} '
      f'FIXED={sum(fixed.values())} REMOVED={sum(removed.values())} '
      f'| goldcov P={sum(gp.values())}/{sum(g.values())} Q={sum(gq.values())}/{sum(g.values())} '
      f'surplus P={sum(xp.values())} Q={sum(xq.values())}')
for lbl, c in (('LOST', lost), ('GAINED', gained)):
    for k, v in c.most_common(12):
        print(f'{tag}\t  {lbl} x{v}\t{k[:150]}')
