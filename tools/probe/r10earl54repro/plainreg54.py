#!/usr/bin/env python3
"""PLAIN-VIEW REGRESSION CHECK (r10earl54 verification).

For the plain (non-elaborated) view, the class that matters is
PRISTINE-RIGHT -> PATCHED-WRONG: a slot where our pristine output already AGREED
with the plain golden and the patch broke it.  Everything else (already-unequal
slots changing shape) is a residue, per earl52-F2's ranking.

  usage: plainreg.py <golden.dump> <pristine.norm> <patched.norm> <label>
"""
import sys
sys.path.insert(0, __file__.rsplit('/', 1)[0])
import census54 as C

g, a, b, lab = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
G, A, B = C.scan(g), C.scan(a), C.scan(b)
keys = set(A) | set(B) | set(G)
broke, fixed, resid, same = [], [], [], 0
for k in sorted(keys):
    gv, av, bv = G.get(k), A.get(k), B.get(k)
    if av == bv:
        same += 1
        continue
    if av == gv and bv != gv:
        broke.append((k, gv, av, bv))
    elif bv == gv and av != gv:
        fixed.append((k, gv, av, bv))
    else:
        resid.append((k, gv, av, bv))
print('%-4s slots g=%d pris=%d pat=%d | unchanged=%d  FIXED=%d  BROKE=%d  residue-reshaped=%d'
      % (lab, len(G), len(A), len(B), same, len(fixed), len(broke), len(resid)))
for tag, lst in (('BROKE(pristine-right->patched-wrong)', broke),
                 ('FIXED', fixed), ('RESHAPED(already unequal)', resid)):
    for k, gv, av, bv in lst:
        print('   %-38s %s  golden=%s pris=%s pat=%s' % (tag, k, gv, av, bv))
