#!/usr/bin/env python3
"""r10uvm214 — THE LAW'S OWN SCORER.  MEASUREMENT ONLY; the official uhdm-cmp
is the sole acceptance judge.  LHS is ALWAYS golden (Surelog).

THE POPULATION.  A `ct214bind --keycount` row is in the law's population when its
HOLDER LISTING is a package's DEF listing of an out-of-body class method —
`package[ALLPKG:<p>]<function|task:<C>::<m><...` — i.e. exactly the listing
`emitPackageClassMethodClones` writes.  Every other holder is out of scope and
is reported separately so an over-fire cannot hide.

THE CELL.  (key, holder) — one package-parameter REFERENCE, named by its own
span and by the declaration chain that holds it.  Its VALUE is the BINDING
payload `ct214bind` prints: the kind and span of what `Actual_group` names, THE
LISTING that object lives in, and a kind-specific discriminator (a constant's
value/decompile/size, an operation's optype, otherwise a name).  A cell is RIGHT
when ours equals golden's, WRONG otherwise.  The LISTING is in the payload on
purpose: a def-view Rhs and its elaborated twin can carry the same value, and
then the judge cannot tell them apart but the BYTES can.

THE FOUR COLUMNS (RESUME §7):
  TO-GOLDEN   pristine WRONG -> patched RIGHT
  AWAY        pristine RIGHT -> patched WRONG          (must be 0)
  MOVED-WRONG pristine WRONG -> patched WRONG, CHANGED (must be 0)
  STILL-WRONG pristine WRONG -> patched WRONG, same
plus APPEARED / VANISHED cells (arity: a copy golden does not mint must not
appear; a copy golden mints that we never had is a residue, not a regression).

TWO SCORINGS, BOTH PRINTED, because they answer different questions:
  * MULTISET   — the view Counter compared exactly.  This is the strict reading
                 and it is the one the corpus rows are scored by.
  * VIEW-SET   — which payloads are named, ignoring multiplicity.  Needed
                 because a golden built with `-elabuhdm` holds a cell 2 or 3
                 times where we hold it once: the MULTIPLICITY is a pre-existing
                 arity residue that this law does not touch, while the BINDING is
                 what the law owns.  Scoring only the multiset would report such
                 a cell as MOVED-WRONG when its binding is now exactly
                 golden's.

usage: score214.py <golden.kc> <pristine.kc> <patched.kc> [--all] [--names]
       (--all drops the def-listing restriction; --names lists every cell)
"""
import re
import sys
from collections import Counter

LAW = re.compile(r"^package\[ALLPKG:[A-Za-z_0-9@]+\]<(function|task):[A-Za-z_0-9]+::")


def load(path, restrict):
    c = Counter()
    with open(path) as f:
        for line in f:
            if not line.startswith("KC\t"):
                continue
            _, key, view, holder, n = line.rstrip("\n").split("\t")
            if restrict and not LAW.match(holder):
                continue
            c[(key, holder, view)] += int(n)
    return c


def cells(c):
    """(key,holder) -> Counter(view -> n)"""
    out = {}
    for (k, h, v), n in c.items():
        out.setdefault((k, h), Counter())[v] += n
    return out


def main():
    restrict = "--all" not in sys.argv
    names = "--names" in sys.argv
    G = cells(load(sys.argv[1], restrict))
    P = cells(load(sys.argv[2], restrict))
    Q = cells(load(sys.argv[3], restrict))
    keys = set(G) | set(P) | set(Q)
    tog, away, movedwrong, stillwrong, right = [], [], [], [], 0
    appeared, vanished = [], []
    vtog = vaway = vmw = vsw = vright = 0
    for k in sorted(keys):
        g, p, q = G.get(k), P.get(k), Q.get(k)
        if g is not None and q is not None and p is not None:
            gs, ps, qs = set(g), set(p), set(q)
            if ps == gs and qs == gs:
                vright += 1
            elif ps != gs and qs == gs:
                vtog += 1
            elif ps == gs and qs != gs:
                vaway += 1
            elif ps != qs:
                vmw += 1
            else:
                vsw += 1
        if g is None and q is not None:
            appeared.append((k, q))
            continue
        if g is not None and q is None:
            vanished.append((k, g))
            continue
        if g is None:
            continue
        pr = (p == g)
        qr = (q == g)
        if pr and qr:
            right += 1
        elif not pr and qr:
            tog.append((k, p, q))
        elif pr and not qr:
            away.append((k, p, q))
        elif p != q:
            movedwrong.append((k, p, q))
        else:
            stillwrong.append((k, p, q))
    print("-- SCOPE %s   cells golden=%d pristine=%d patched=%d"
          % ("DEF-LISTING" if restrict else "ALL", len(G), len(P), len(Q)))
    print("-- VIEWSET RIGHT-BOTH %d  TO-GOLDEN %d  AWAY-GOLDEN %d  "
          "MOVED-WRONG %d  STILL-WRONG %d"
          % (vright, vtog, vaway, vmw, vsw))
    print("-- RIGHT-BOTH %d  TO-GOLDEN %d  AWAY-GOLDEN %d  MOVED-WRONG %d  "
          "STILL-WRONG %d  APPEARED %d  VANISHED %d"
          % (right, len(tog), len(away), len(movedwrong), len(stillwrong),
             len(appeared), len(vanished)))
    if names:
        for tag, lst in (("TO-GOLDEN", tog), ("AWAY-GOLDEN", away),
                         ("MOVED-WRONG", movedwrong)):
            for (k, p, q) in lst:
                print("%s\t%s\t%s\tpristine=%s\tpatched=%s\tgolden=%s"
                      % (tag, k[0], k[1], dict(p or {}), dict(q or {}),
                         dict(G[k])))
        for (k, q) in appeared:
            print("APPEARED\t%s\t%s\tpatched=%s" % (k[0], k[1], dict(q)))


if __name__ == "__main__":
    main()
