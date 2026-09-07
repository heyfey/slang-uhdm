#!/usr/bin/env python3
"""r10earl114 -- the THREE-FAMILY arm scorer (PX / P0 / PR), SHAPE and STRICT.

MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
LHS is ALWAYS golden; RHS is ALWAYS ours.

`score114.py` scores the PX family, whose KEY carries the root kind and the
whole matrix -- the READING instrument.  That key hides one thing on purpose:
a cell where OUR root kind differs from golden's lands in NOGOLD rather than
being compared.  This scorer therefore also runs the COARSE families, whose key
is span + VpiName ALONE:

  P0  every hier_path's typespec edge          <- the law's own field
  PR  every hier_path's OTHER compare-visible fields (VpiSize, VpiDecompile,
      VpiDefName, Root_value kind, the Path_elems list with each element's
      Actual_group / index kind)               <- "nothing else moved"

The P0 family is what convicted the first cut of this law: five gen-local-root
cells were SHAPE-AWAY there while the PX family called them NOGOLD.  Both are
printed; a law is acceptable only when AWAY and MOVEDWRONG are 0 in EVERY
family.

Payload SETS (SHAPE) are the judged score and payload MULTISETS (STRICT) are
printed beside them: arena copy COUNTS are read by no generated Compare
(r10earl111/112/113's precedent) and must not manufacture a verdict.

  usage: fam114.py <armdir> [<armdir> ...]
"""
import collections
import os
import sys

FAMS = ("PX", "P0", "PR")


def load(path, fam):
    if not os.path.exists(path):
        return None
    d = collections.defaultdict(collections.Counter)
    rc = None
    for line in open(path):
        line = line.rstrip("\n")
        if line.startswith("CENRC "):
            rc = int(line.split()[1])
            continue
        if "|" + fam + "|" not in line:
            continue
        p = line.split("\t")
        if len(p) < 3:
            continue
        d[p[0]][p[1]] += int(p[2])
    if rc != 0:
        sys.exit("FATAL: %s did not end CENRC 0 (rc=%s)" % (path, rc))
    return d


def score(g, p, q):
    setof = frozenset
    out = collections.Counter()
    bad = []
    for k in sorted(set(g) | set(p) | set(q)):
        G, P, Q = g.get(k), p.get(k), q.get(k)
        if G is None:
            v = "NOGOLD" if P != Q else "NOGOLD_UNMOVED"
        elif P is None and Q is None:
            v = "ONESIDED"
        elif P is None or Q is None:
            v = "ONESIDED_MOVED"
        else:
            sG, sP, sQ = setof(G), setof(P), setof(Q)
            if sP == sG and sQ == sG:
                v = "SAME_AGREE"
            elif sP != sG and sQ == sG:
                v = "TOGOLD"
            elif sP == sG and sQ != sG:
                v = "AWAY"
            elif sP == sQ:
                v = "STILLWRONG"
            else:
                v = "MOVEDWRONG"
        out[v] += 1
        if v in ("AWAY", "MOVEDWRONG", "ONESIDED_MOVED", "NOGOLD"):
            bad.append((v, k, G, P, Q))
    return out, bad


def main(argv):
    tot = {f: collections.Counter() for f in FAMS}
    allbad = []
    for arm in argv:
        name = os.path.basename(arm.rstrip("/"))
        for fam in FAMS:
            g = load(os.path.join(arm, "cen.gold.txt"), fam)
            p = load(os.path.join(arm, "cen.pris.txt"), fam)
            q = load(os.path.join(arm, "cen.patch.txt"), fam)
            if g is None or p is None or q is None:
                print("MISSING CENSUS in %s" % arm)
                return 2
            c, bad = score(g, p, q)
            tot[fam].update(c)
            allbad += [(name, fam) + b for b in bad]
            print("%-24s %-3s %s" % (name, fam,
                                     "  ".join("%s=%d" % (a, b)
                                               for a, b in sorted(c.items()))))
    for fam in FAMS:
        print("-- TOTAL %-3s %s" % (fam, "  ".join(
            "%s=%d" % (a, b) for a, b in sorted(tot[fam].items()))))
    for name, fam, v, k, G, P, Q in allbad:
        print("   [%s] %s %s %s" % (v, fam, name, k))
        print("       G:%s" % (dict(G) if G is not None else None))
        print("       P:%s" % (dict(P) if P is not None else None))
        print("       Q:%s" % (dict(Q) if Q is not None else None))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
